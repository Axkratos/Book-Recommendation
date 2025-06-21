import dotenv from "dotenv";
import { app } from "./app.js";
import connectDB from './db/index.js'

dotenv.config({
    path: './env'
})
connectDB().then(
    ()=>{
        app.on('error',(err)=>{
            console.log("Internal Server Error",err);
            throw err;
        })
        app.listen(process.env.PORT || 8000,()=>{
            console.log(`Server is Listening at port ${process.env.PORT}`);
        })
    }
).catch(
    (err)=>{
        console.log("Mongodb Connection failed : ",err)
    }
);
// import dotenv from "dotenv";
// import { app } from "./app.js";
// import connectDB from './db/index.js';
// import os from 'os';

// dotenv.config({
//   path: './env'
// });

// connectDB().then(() => {
//   console.log("✅ MongoDB connected");

//   app.on('error', (err) => {
//     console.error("🔴 Internal Server Error", err);
//     throw err;
//   });

//   const PORT = process.env.PORT || 8000;
//   const HOST = '0.0.0.0';

//   app.listen(PORT, HOST, () => {
//     console.log(`✅ Server is listening on ${HOST}:${PORT}`);

//     // Log all non-internal IPv4 addresses for LAN access
//     const nets = os.networkInterfaces();
//     Object.values(nets).flat().forEach(iface => {
//       if (iface.family === 'IPv4' && !iface.internal) {
//         console.log(`   • LAN URL → http://${iface.address}:${PORT}`);
//       }
//     });
//   });

// }).catch((err) => {
//   console.error("🔴 MongoDB Connection failed:", err);
// });
