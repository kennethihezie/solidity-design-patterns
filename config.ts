import path from "path"
import fs from "fs"

const filePath = path.resolve(__dirname, 'artifacts/contracts', 'DesignPattern.sol', 'DesignPattern.json')
const src = fs.readFileSync(filePath, 'utf8')
module.exports = JSON.parse(src)