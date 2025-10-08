import { cartoonify } from "../ai/flows/cartoonify.js";
import { illustrate } from "../ai/flows/illustrate.js";
import { storify } from "../ai/flows/storify.js";
import { expressHandler } from "@genkit-ai/express";
import express from "express";
import cors from "cors";
import ViteExpress from "vite-express";

const app = express();
app.use(express.json({ limit: "10mb" }));
app.use(cors({origin: '*'}));

app.get("/hello", (_, res) => {
  res.send("Hello Vite + React + TypeScript!");
});

app.post("/api/cartoonify", expressHandler(cartoonify));
app.post("/api/storify", expressHandler(storify));
app.post("/api/illustrate", expressHandler(illustrate));

ViteExpress.listen(app, 3000, () =>
  console.log("Server is listening on port 3000..."),
);
