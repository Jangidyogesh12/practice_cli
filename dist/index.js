"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const commander_1 = require("commander");
const hello = () => {
    console.log("Hello, world!");
};
const program = new commander_1.Command();
program.command("hello").description("Say hello").action(hello);
program.parse(process.argv);
