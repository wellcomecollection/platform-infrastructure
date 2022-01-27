# How to log into an account using the AWS console

1.  Visit <https://myapps.microsoft.com/>.
    Log in using your `c_` account, e.g. `c_chana@wellcome.ac.uk`.

2.  You should see a list of apps.
    Click the app named "AWS - Digital Platform".

    If you can't see that app, it means you don't have access to our AWS accounts.
    Talk to a/another developer.

    <img src="./wellcomecloud-screenshot.png" alt="A panel of five app icons arranged in a grid. The leftmost icon is the AWS logo with the label 'AWS - Digital Platform'; it's highlighted with a grey border.">

3.  You should be taken to the AWS console.

    <img src="./aws-console.png" alt="Screenshot of the AWS Management Console homepage. There's a top menu bar, a list of services, and a footer.">

4.  Your default role can't do anything; it can only assume specific roles in other accounts.
    To assume a role, click the menu in the top right-hand corner, and click "Switch Role".

    <img src="./assume-role-menu.png" alt="The same homepage as previously, but now with a dropdown menu coming from the top right-hand corner. At the bottom are two buttons: 'Switch role' and 'Sign out'.">

5.  You should be taken to a "Switch Role" screen.
    Enter the account ID and name of the role you want to assume, then click "Switch Role".

    <img src="./assume-role-switcher.png" alt="A 'Switch Role' form with three fields: Account, Role, and Display Name. There's also a colour picker and a 'Switch Role' button.">
