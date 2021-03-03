export type GetBNumberResult = string | Error

export function getBnumberFromPath(path: string): GetBNumberResult {
    const splitPath = path.split("/")
    const bNumberRegexp = /^b[0-9]{8}/

    if(splitPath.length != 3) {
        return Error(`Path ${path} has the wrong number many elements (expected 3)`)
    }

    if(splitPath[0] != "") {
        return Error(`Path ${path} does not start with /`)
    }

    if(splitPath[1] != "item") {
        return Error(`Path ${path} does not start with /item`)
    }

    if(!bNumberRegexp.test(splitPath[2])) {
        return Error(`b number in ${path} does not match ${bNumberRegexp}`)
    }

    return splitPath[2]
}