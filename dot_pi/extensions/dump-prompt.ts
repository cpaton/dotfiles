import type { PiExtension } from "pi-ai";

const ext: PiExtension = (pi) => {
  pi.on("before_agent_start", (event, ctx) => {
    const fs = require("fs");
    fs.writeFileSync("/tmp/pi-system-prompt.txt", event.systemPrompt);
    console.error("[dump-prompt] System prompt written to /tmp/pi-system-prompt.txt");
  });
};

export default ext;
