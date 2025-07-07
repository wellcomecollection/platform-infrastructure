#!/usr/bin/env python3

import boto3
from datetime import datetime
from dateutil.relativedelta import relativedelta
import os
import argparse
import sys

# ANSI color codes for terminal output
class Colors:
    RED = '\033[91m'
    GREEN = '\033[92m'
    YELLOW = '\033[93m'
    BLUE = '\033[94m'
    MAGENTA = '\033[95m'
    CYAN = '\033[96m'
    WHITE = '\033[97m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'
    END = '\033[0m'  # End formatting

# --- Configuration ---
# Map of developer roles - account name to ARN mapping
developer_roles = {
    "catalogue": "arn:aws:iam::756629837203:role/catalogue-developer",
    "data": "arn:aws:iam::964279923020:role/data-developer",
    "digirati": "arn:aws:iam::653428163053:role/digirati-developer",
    "digitisation": "arn:aws:iam::404315009621:role/digitisation-developer",
    "experience": "arn:aws:iam::130871440101:role/experience-developer",
    "identity": "arn:aws:iam::770700576653:role/identity-developer",
    "microsites": "arn:aws:iam::782179017633:role/microsites-developer",
    "platform": "arn:aws:iam::760097843905:role/platform-developer",
    "reporting": "arn:aws:iam::269807742353:role/reporting-developer",
    "storage": "arn:aws:iam::975596993436:role/storage-developer",
    "systems_strategy": "arn:aws:iam::487094370410:role/systems_strategy-developer",
    "workflow": "arn:aws:iam::299497370133:role/workflow-developer",
}

# A descriptive name for the STS session.
ROLE_SESSION_NAME = "CostExplorerSession"
# ---------------------

def assume_role(role_arn, role_session_name):
    """
    Assumes the specified IAM role and returns temporary credentials.
    """
    try:
        sts_client = boto3.client("sts")
        assumed_role_object = sts_client.assume_role(
            RoleArn=role_arn, RoleSessionName=role_session_name
        )
        return assumed_role_object["Credentials"]
    except Exception as e:
        print(f"Error assuming role: {e}")
        return None

def set_ssm_parameter(credentials, parameter_name, parameter_value):
    """
    Sets an SSM parameter value.
    """
    try:
        # Create SSM client using the assumed role's credentials
        ssm_client = boto3.client(
            "ssm",
            aws_access_key_id=credentials["AccessKeyId"],
            aws_secret_access_key=credentials["SecretAccessKey"],
            aws_session_token=credentials["SessionToken"],
        )
        
        # Set the parameter
        ssm_client.put_parameter(
            Name=parameter_name,
            Value=parameter_value,
            Type='String',
            Overwrite=True
        )
        return True
    except Exception as e:
        print(f"Error setting SSM parameter {parameter_name}: {e}")
        return False

def initialize_budget_parameters(credentials, role_arn, budget_percentage=110, email_address="digital@wellcomecollection.org"):
    """
    Initializes budget parameters based on spending data.
    """
    try:
        role_name = role_arn.split('/')[-1]
        
        # Get cost data to calculate budget
        ce_client = boto3.client(
            "ce",
            aws_access_key_id=credentials["AccessKeyId"],
            aws_secret_access_key=credentials["SecretAccessKey"],
            aws_session_token=credentials["SessionToken"],
        )

        # Calculate the time period for the last 6 full months
        end_date = datetime.now().replace(day=1).strftime("%Y-%m-%d")
        start_date = (datetime.now() - relativedelta(months=6)).replace(day=1).strftime("%Y-%m-%d")

        # Get cost and usage data
        response = ce_client.get_cost_and_usage(
            TimePeriod={"Start": start_date, "End": end_date},
            Granularity="MONTHLY",
            Metrics=["UnblendedCost"],
        )

        total_cost = 0
        for result in response["ResultsByTime"]:
            amount = float(result["Total"]["UnblendedCost"]["Amount"])
            total_cost += amount

        average_cost = total_cost / len(response["ResultsByTime"]) if response["ResultsByTime"] else 0
        budget_amount = int(average_cost * (budget_percentage / 100))

        # Set the budget parameters
        monthly_param_set = set_ssm_parameter(credentials, '/platform/budget/monthly', str(budget_amount))
        email_param_set = set_ssm_parameter(credentials, '/platform/budget/email_notifications', email_address)

        print(f"\n--- Budget Initialization for {role_name} ---")
        print(f"Average monthly spend (last 6 months): ${average_cost:.2f}")
        print(f"Budget percentage: {budget_percentage}%")
        print(f"Calculated budget: ${budget_amount}")
        
        if monthly_param_set:
            print(f"✓ Monthly budget parameter set: ${budget_amount}")
        else:
            print("✗ Failed to set monthly budget parameter")
            
        if email_param_set:
            print(f"✓ Email notifications parameter set: {email_address}")
        else:
            print("✗ Failed to set email notifications parameter")
            
        print("-" * 50)
        
        return monthly_param_set and email_param_set

    except Exception as e:
        print(f"Error initializing budget parameters for {role_name}: {e}")
        return False

def get_ssm_parameters(credentials):
    """
    Gets the SSM parameters for budget configuration.
    """
    budget_params = {
        'monthly': None,
        'email_notifications': None
    }
    
    try:
        # Create SSM client using the assumed role's credentials
        ssm_client = boto3.client(
            "ssm",
            aws_access_key_id=credentials["AccessKeyId"],
            aws_secret_access_key=credentials["SecretAccessKey"],
            aws_session_token=credentials["SessionToken"],
        )
        
        # Try to get both parameters
        param_names = ['/platform/budget/monthly', '/platform/budget/email_notifications']
        
        try:
            response = ssm_client.get_parameters(Names=param_names)
            for param in response['Parameters']:
                if param['Name'] == '/platform/budget/monthly':
                    budget_params['monthly'] = param['Value']
                elif param['Name'] == '/platform/budget/email_notifications':
                    budget_params['email_notifications'] = param['Value']
        except Exception:
            # If batch get fails, try individual parameters
            for param_name in param_names:
                try:
                    response = ssm_client.get_parameter(Name=param_name)
                    if param_name == '/platform/budget/monthly':
                        budget_params['monthly'] = response['Parameter']['Value']
                    elif param_name == '/platform/budget/email_notifications':
                        budget_params['email_notifications'] = response['Parameter']['Value']
                except Exception:
                    pass  # Parameter doesn't exist, keep as None
                    
    except Exception:
        pass  # SSM access failed, keep defaults
    
    return budget_params

def get_current_month_cost_and_forecast(credentials):
    """
    Gets current month cost and forecast for the month.
    """
    try:
        ce_client = boto3.client(
            "ce",
            aws_access_key_id=credentials["AccessKeyId"],
            aws_secret_access_key=credentials["SecretAccessKey"],
            aws_session_token=credentials["SessionToken"],
        )
        
        # Current month dates
        now = datetime.now()
        current_month_start = now.replace(day=1).strftime("%Y-%m-%d")
        next_month_start = (now.replace(day=1) + relativedelta(months=1)).strftime("%Y-%m-%d")
        
        # Get current month actual cost
        current_response = ce_client.get_cost_and_usage(
            TimePeriod={"Start": current_month_start, "End": next_month_start},
            Granularity="MONTHLY",
            Metrics=["UnblendedCost"],
        )
        
        current_cost = 0
        if current_response["ResultsByTime"]:
            current_cost = float(current_response["ResultsByTime"][0]["Total"]["UnblendedCost"]["Amount"])
        
        # Get forecast for current month
        forecast_response = ce_client.get_cost_and_usage(
            TimePeriod={"Start": current_month_start, "End": next_month_start},
            Granularity="MONTHLY",
            Metrics=["UnblendedCost"],
            GroupBy=[{"Type": "DIMENSION", "Key": "SERVICE"}]
        )
        
        # Try to get forecast using dimension forecast
        try:
            forecast_response = ce_client.get_dimension_values(
                TimePeriod={"Start": current_month_start, "End": next_month_start},
                Dimension="SERVICE",
                Context="FORECASTING"
            )
            forecast_cost = current_cost * 1.1  # Fallback estimate
        except:
            # Estimate forecast as current cost * (days in month / days elapsed)
            days_in_month = (now.replace(day=1) + relativedelta(months=1) - relativedelta(days=1)).day
            days_elapsed = now.day
            if days_elapsed > 0:
                forecast_cost = current_cost * (days_in_month / days_elapsed)
            else:
                forecast_cost = current_cost
                
        return current_cost, forecast_cost
        
    except Exception:
        return 0, 0

def get_last_month_cost(credentials):
    """
    Gets the cost for the previous month.
    """
    try:
        ce_client = boto3.client(
            "ce",
            aws_access_key_id=credentials["AccessKeyId"],
            aws_secret_access_key=credentials["SecretAccessKey"],
            aws_session_token=credentials["SessionToken"],
        )
        
        # Last month dates
        now = datetime.now()
        last_month_start = (now.replace(day=1) - relativedelta(months=1)).strftime("%Y-%m-%d")
        current_month_start = now.replace(day=1).strftime("%Y-%m-%d")
        
        # Get last month cost
        response = ce_client.get_cost_and_usage(
            TimePeriod={"Start": last_month_start, "End": current_month_start},
            Granularity="MONTHLY",
            Metrics=["UnblendedCost"],
        )
        
        if response["ResultsByTime"]:
            return float(response["ResultsByTime"][0]["Total"]["UnblendedCost"]["Amount"])
        return 0
        
    except Exception:
        return 0

def format_budget_status(current_cost, forecast_cost, budget_amount):
    """
    Format budget status with colors and emojis.
    """
    if not budget_amount:
        return f"{Colors.YELLOW}⚠️  Budget: UNSET{Colors.END}"
    
    budget_val = float(budget_amount)
    current_pct = (current_cost / budget_val) * 100 if budget_val > 0 else 0
    forecast_pct = (forecast_cost / budget_val) * 100 if budget_val > 0 else 0
    
    status_parts = []
    
    # Current status
    if current_pct >= 110:
        status_parts.append(f"{Colors.RED}🚨 Current: ${current_cost:.0f} ({current_pct:.0f}%){Colors.END}")
    elif current_pct >= 100:
        status_parts.append(f"{Colors.YELLOW}⚠️  Current: ${current_cost:.0f} ({current_pct:.0f}%){Colors.END}")
    elif current_pct >= 80:
        status_parts.append(f"{Colors.BLUE}ℹ️  Current: ${current_cost:.0f} ({current_pct:.0f}%){Colors.END}")
    else:
        status_parts.append(f"{Colors.GREEN}✅ Current: ${current_cost:.0f} ({current_pct:.0f}%){Colors.END}")
    
    # Forecast status
    if forecast_pct >= 110:
        status_parts.append(f"{Colors.RED}🚨 Forecast: ${forecast_cost:.0f} ({forecast_pct:.0f}%){Colors.END}")
    elif forecast_pct >= 100:
        status_parts.append(f"{Colors.YELLOW}⚠️  Forecast: ${forecast_cost:.0f} ({forecast_pct:.0f}%){Colors.END}")
    else:
        status_parts.append(f"{Colors.GREEN}📈 Forecast: ${forecast_cost:.0f} ({forecast_pct:.0f}%){Colors.END}")
    
    return f"Budget: ${budget_val:.0f} | " + " | ".join(status_parts)

def get_cost_and_usage(credentials, role_arn):
    """
    Gets the total and average cost for the last 6 months using the provided credentials.
    """
    if not credentials:
        return

    try:
        # Extract account name from role ARN for display
        account_name = role_arn.split(':')[4]
        role_name = role_arn.split('/')[-1]
        
        # Create a Cost Explorer client using the assumed role's credentials
        ce_client = boto3.client(
            "ce",
            aws_access_key_id=credentials["AccessKeyId"],
            aws_secret_access_key=credentials["SecretAccessKey"],
            aws_session_token=credentials["SessionToken"],
        )

        # Calculate the time period for the last 6 full months
        end_date = datetime.now().replace(day=1).strftime("%Y-%m-%d")
        start_date = (datetime.now() - relativedelta(months=6)).replace(day=1).strftime("%Y-%m-%d")

        # Get cost and usage data
        response = ce_client.get_cost_and_usage(
            TimePeriod={"Start": start_date, "End": end_date},
            Granularity="MONTHLY",
            Metrics=["UnblendedCost"],
        )

        total_cost = 0
        monthly_costs = []

        for result in response["ResultsByTime"]:
            amount = float(result["Total"]["UnblendedCost"]["Amount"])
            unit = result["Total"]["UnblendedCost"]["Unit"]
            start_period = result["TimePeriod"]["Start"]
            total_cost += amount
            monthly_costs.append(f"  - {start_period[:7]}: ${amount:.2f}")

        average_cost = total_cost / len(response["ResultsByTime"]) if response["ResultsByTime"] else 0

        # Get current and last month data
        current_cost, forecast_cost = get_current_month_cost_and_forecast(credentials)
        last_month_cost = get_last_month_cost(credentials)
        
        # Get SSM budget parameters
        budget_params = get_ssm_parameters(credentials)

        # Print the results
        print(f"\n{Colors.BOLD}{Colors.CYAN}=== AWS Cost Report for {role_name} (Account: {account_name}) ==={Colors.END}")
        print(f"\n📊 {Colors.BOLD}6-Month Analysis:{Colors.END}")
        print(f"   Total spend (6 months): ${total_cost:.2f}")
        print(f"   Average monthly spend: ${average_cost:.2f}")
        
        print(f"\n📈 {Colors.BOLD}Recent Activity:{Colors.END}")
        print(f"   Last month: ${last_month_cost:.2f}")
        print(f"   Current month (to date): ${current_cost:.2f}")
        print(f"   Current month forecast: ${forecast_cost:.2f}")
        
        # Display budget status
        print(f"\n💰 {Colors.BOLD}Budget Status:{Colors.END}")
        if budget_params['monthly']:
            status = format_budget_status(current_cost, forecast_cost, budget_params['monthly'])
            print(f"   {status}")
        else:
            print(f"   {Colors.YELLOW}⚠️  Monthly budget: UNSET{Colors.END}")
            
        if budget_params['email_notifications']:
            print(f"   📧 Email notifications: {budget_params['email_notifications']}")
        else:
            print(f"   {Colors.YELLOW}⚠️  Email notifications: UNSET{Colors.END}")
        
        print(f"\n📅 {Colors.BOLD}Monthly Breakdown (Last 6 Months):{Colors.END}")
        for month in monthly_costs:
            print(month)
        print("-" * 80)

        return total_cost, average_cost, unit, budget_params, current_cost, forecast_cost, last_month_cost

    except Exception as e:
        print(f"Error getting cost and usage data for {role_name}: {e}")
        return None, None, None, None, None, None, None

def get_cost_and_usage_silent(credentials, role_arn):
    """
    Gets the total and average cost for the last 6 months using the provided credentials.
    This version doesn't print individual account details (for summary-only mode).
    """
    if not credentials:
        return None, None, None, None

    try:
        # Extract role name from role ARN for error reporting
        role_name = role_arn.split('/')[-1]
        
        # Create a Cost Explorer client using the assumed role's credentials
        ce_client = boto3.client(
            "ce",
            aws_access_key_id=credentials["AccessKeyId"],
            aws_secret_access_key=credentials["SecretAccessKey"],
            aws_session_token=credentials["SessionToken"],
        )

        # Calculate the time period for the last 6 full months
        end_date = datetime.now().replace(day=1).strftime("%Y-%m-%d")
        start_date = (datetime.now() - relativedelta(months=6)).replace(day=1).strftime("%Y-%m-%d")

        # Get cost and usage data
        response = ce_client.get_cost_and_usage(
            TimePeriod={"Start": start_date, "End": end_date},
            Granularity="MONTHLY",
            Metrics=["UnblendedCost"],
        )

        total_cost = 0
        for result in response["ResultsByTime"]:
            amount = float(result["Total"]["UnblendedCost"]["Amount"])
            unit = result["Total"]["UnblendedCost"]["Unit"]
            total_cost += amount

        average_cost = total_cost / len(response["ResultsByTime"]) if response["ResultsByTime"] else 0

        # Get current and last month data
        current_cost, forecast_cost = get_current_month_cost_and_forecast(credentials)
        last_month_cost = get_last_month_cost(credentials)

        # Get SSM budget parameters
        budget_params = get_ssm_parameters(credentials)

        return total_cost, average_cost, unit, budget_params, current_cost, forecast_cost, last_month_cost

    except Exception as e:
        print(f"Error getting cost and usage data for {role_name}: {e}")
        return None, None, None, None, None, None, None

def create_argument_parser():
    """
    Creates and configures the argument parser for the CLI.
    """
    account_names = ", ".join(sorted(developer_roles.keys()))
    
    parser = argparse.ArgumentParser(
        description="AWS Cost Analysis Tool - Analyze spending across developer accounts",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=f"""
Examples:
  %(prog)s --all                           # Show all accounts with summary
  %(prog)s --summary-only                  # Show only the summary
  %(prog)s --account catalogue             # Show only catalogue account
  %(prog)s --account platform --account storage  # Show multiple accounts
  %(prog)s --list-accounts                 # List all available accounts
  %(prog)s --init-budget catalogue         # Initialize budget for catalogue account
  %(prog)s --init-budget platform --budget-percentage 120  # Set budget to 120%% of average spend
  %(prog)s --init-budget storage --email-address team@example.com  # Set custom email
  %(prog)s --init-all-budgets              # Initialize budget for all accounts
  %(prog)s --init-all-budgets --budget-percentage 105  # Initialize all with 105%% budget

Available accounts:
  {account_names}
        """
    )
    
    group = parser.add_mutually_exclusive_group()
    group.add_argument(
        "--all",
        action="store_true",
        help="Show cost analysis for all accounts (default behavior)"
    )
    group.add_argument(
        "--summary-only",
        action="store_true",
        help="Show only the summary across all accounts"
    )
    group.add_argument(
        "--account",
        action="append",
        help="Specify individual account(s) to analyze (can be used multiple times)"
    )
    group.add_argument(
        "--list-accounts",
        action="store_true",
        help="List all available accounts and exit"
    )
    group.add_argument(
        "--init-budget",
        action="append",
        help="Initialize budget parameters for specified account(s) (can be used multiple times)"
    )
    group.add_argument(
        "--init-all-budgets",
        action="store_true",
        help="Initialize budget parameters for all accounts"
    )
    
    parser.add_argument(
        "--budget-percentage",
        type=float,
        default=110.0,
        help="Percentage of average monthly spend to set as budget (default: 110%%)"
    )
    parser.add_argument(
        "--email-address",
        type=str,
        default="digital@wellcomecollection.org",
        help="Email address for budget notifications (default: digital@wellcomecollection.org)"
    )
    
    return parser

def list_available_accounts():
    """
    Lists all available accounts and their ARNs.
    """
    print("Available developer accounts:")
    print("=" * 50)
    for account_name, role_arn in sorted(developer_roles.items()):
        account_id = role_arn.split(':')[4]
        role_name = role_arn.split('/')[-1]
        print(f"  {account_name:<20} -> {role_name:<30} (Account: {account_id})")
    print("=" * 50)

def get_role_arn_by_name(account_name):
    """
    Gets the full role ARN by account name.
    """
    return developer_roles.get(account_name)

if __name__ == "__main__":
    parser = create_argument_parser()
    args = parser.parse_args()
    
    # Show help if no arguments provided
    if len(sys.argv) == 1:
        parser.print_help()
        sys.exit(0)
    
    # Handle list accounts command
    if args.list_accounts:
        list_available_accounts()
        sys.exit(0)
    
    # Handle budget initialization
    if args.init_budget:
        print("=" * 80)
        print("BUDGET PARAMETER INITIALIZATION")
        print("=" * 80)
        
        success_count = 0
        for account_name in args.init_budget:
            role_arn = get_role_arn_by_name(account_name)
            if role_arn:
                print(f"\nInitializing budget for {account_name}...")
                assumed_role_credentials = assume_role(role_arn, ROLE_SESSION_NAME)
                if assumed_role_credentials:
                    if initialize_budget_parameters(
                        assumed_role_credentials, 
                        role_arn, 
                        args.budget_percentage,
                        args.email_address
                    ):
                        success_count += 1
                else:
                    print(f"Failed to assume role for {account_name}")
            else:
                print(f"Error: Unknown account '{account_name}'")
                print("Use --list-accounts to see available accounts")
                sys.exit(1)
        
        print(f"\n{success_count} out of {len(args.init_budget)} accounts initialized successfully.")
        sys.exit(0)
    
    # Handle initialization of all budgets
    if args.init_all_budgets:
        print("=" * 80)
        print("BUDGET PARAMETER INITIALIZATION - ALL ACCOUNTS")
        print("=" * 80)
        print(f"Initializing budget parameters for all {len(developer_roles)} accounts...")
        print(f"Budget percentage: {args.budget_percentage}%")
        print(f"Email address: {args.email_address}")
        print("-" * 80)
        
        success_count = 0
        total_accounts = len(developer_roles)
        
        for account_name, role_arn in developer_roles.items():
            print(f"\nInitializing budget for {account_name}...")
            assumed_role_credentials = assume_role(role_arn, ROLE_SESSION_NAME)
            if assumed_role_credentials:
                if initialize_budget_parameters(
                    assumed_role_credentials, 
                    role_arn, 
                    args.budget_percentage,
                    args.email_address
                ):
                    success_count += 1
            else:
                print(f"Failed to assume role for {account_name}")
        
        print(f"\n" + "=" * 80)
        print(f"INITIALIZATION COMPLETE: {success_count} out of {total_accounts} accounts initialized successfully.")
        if success_count < total_accounts:
            print(f"Failed to initialize {total_accounts - success_count} accounts.")
        print("=" * 80)
        sys.exit(0)
    
    # Determine which accounts to process
    roles_to_process = []
    
    if args.account:
        # Validate account names and build role list
        for account_name in args.account:
            role_arn = get_role_arn_by_name(account_name)
            if role_arn:
                roles_to_process.append(role_arn)
            else:
                print(f"Error: Unknown account '{account_name}'")
                print("Use --list-accounts to see available accounts")
                sys.exit(1)
    else:
        # Default to all accounts
        roles_to_process = list(developer_roles.values())
    
    total_all_accounts = 0
    successful_accounts = 0
    account_summaries = []
    
    for role_arn in roles_to_process:
        role_name = role_arn.split('/')[-1]
        if not args.summary_only:
            print(f"\nProcessing {role_name}...")
        
        assumed_role_credentials = assume_role(role_arn, ROLE_SESSION_NAME)
        if assumed_role_credentials:
            if args.summary_only:
                # For summary only, don't print individual reports
                total_cost, average_cost, unit, budget_params, current_cost, forecast_cost, last_month_cost = get_cost_and_usage_silent(assumed_role_credentials, role_arn)
            else:
                total_cost, average_cost, unit, budget_params, current_cost, forecast_cost, last_month_cost = get_cost_and_usage(assumed_role_credentials, role_arn)
            
            if total_cost is not None:
                total_all_accounts += total_cost
                successful_accounts += 1
                account_summaries.append({
                    'role': role_name,
                    'total': total_cost,
                    'average': average_cost,
                    'unit': unit,
                    'budget_params': budget_params,
                    'current_cost': current_cost,
                    'forecast_cost': forecast_cost,
                    'last_month_cost': last_month_cost
                })
        else:
            if not args.summary_only:
                print(f"Failed to assume role: {role_name}")
    
    # Print overall summary
    if successful_accounts > 0:
        print(f"\n{Colors.BOLD}{Colors.MAGENTA}{'=' * 80}{Colors.END}")
        print(f"{Colors.BOLD}{Colors.MAGENTA}🏆 SUMMARY ACROSS ALL ACCOUNTS{Colors.END}")
        print(f"{Colors.BOLD}{Colors.MAGENTA}{'=' * 80}{Colors.END}")
        print(f"📊 Total accounts processed: {Colors.BOLD}{successful_accounts}{Colors.END}")
        print(f"💰 Grand total spend (6 months): {Colors.BOLD}${total_all_accounts:.2f}{Colors.END}")
        print(f"📈 Average spend per account (6 months): {Colors.BOLD}${total_all_accounts/successful_accounts:.2f}{Colors.END}")
        
        # Calculate totals for current month and forecasts
        total_current = sum(acc.get('current_cost', 0) for acc in account_summaries)
        total_forecast = sum(acc.get('forecast_cost', 0) for acc in account_summaries)
        total_last_month = sum(acc.get('last_month_cost', 0) for acc in account_summaries)
        
        print(f"📅 Last month total: {Colors.BOLD}${total_last_month:.2f}{Colors.END}")
        print(f"📊 Current month total (to date): {Colors.BOLD}${total_current:.2f}{Colors.END}")
        print(f"🔮 Current month forecast total: {Colors.BOLD}${total_forecast:.2f}{Colors.END}")
        
        print(f"\n{Colors.BOLD}📋 Account Details (sorted by 6-month spend):{Colors.END}")
        account_summaries.sort(key=lambda x: x['total'], reverse=True)
        
        for i, account in enumerate(account_summaries, 1):
            budget_status = ""
            if account['budget_params'] and account['budget_params']['monthly']:
                budget_val = float(account['budget_params']['monthly'])
                current_cost = account.get('current_cost', 0)
                forecast_cost = account.get('forecast_cost', 0)
                
                # Budget status with colors
                if current_cost >= budget_val * 1.1 or forecast_cost >= budget_val * 1.1:
                    budget_emoji = "🚨"
                    budget_color = Colors.RED
                elif current_cost >= budget_val or forecast_cost >= budget_val:
                    budget_emoji = "⚠️"
                    budget_color = Colors.YELLOW
                else:
                    budget_emoji = "✅"
                    budget_color = Colors.GREEN
                    
                budget_status = f"{budget_color}{budget_emoji} Budget: ${budget_val:.0f}{Colors.END}"
                
                # Email status
                if account['budget_params']['email_notifications']:
                    email_count = len(account['budget_params']['email_notifications'].split(','))
                    budget_status += f" | 📧 {email_count} emails"
                else:
                    budget_status += f" | {Colors.YELLOW}⚠️  No emails{Colors.END}"
            else:
                budget_status = f"{Colors.YELLOW}⚠️  Budget: UNSET | ⚠️  No emails{Colors.END}"
            
            # Account line with enhanced formatting
            print(f"{Colors.BOLD}{i:2d}.{Colors.END} {account['role']:<25}: "
                  f"{Colors.BOLD}${account['total']:>8.0f}{Colors.END} (6mo) | "
                  f"${account.get('last_month_cost', 0):>6.0f} (last) | "
                  f"${account.get('current_cost', 0):>6.0f} (curr) | "
                  f"${account.get('forecast_cost', 0):>6.0f} (fcst) | {budget_status}")
        
        print(f"\n{Colors.BOLD}{Colors.BLUE}Legend:{Colors.END}")
        print(f"  6mo = 6-month total | last = last month | curr = current month to date | fcst = current month forecast")
        print(f"  {Colors.GREEN}✅ = Within budget{Colors.END} | {Colors.YELLOW}⚠️  = At/near budget{Colors.END} | {Colors.RED}🚨 = Over budget{Colors.END}")
        print(f"{Colors.BOLD}{Colors.MAGENTA}{'=' * 80}{Colors.END}")
    else:
        print(f"\n{Colors.RED}❌ No accounts could be processed successfully.{Colors.END}")