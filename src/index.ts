#!/usr/bin/env node

import { Command } from "commander";

const hello = () => {
  console.log("Hello, world!");
};

const program = new Command();

program.command("hello").description("Say hello").action(hello);

program.parse(process.argv);
