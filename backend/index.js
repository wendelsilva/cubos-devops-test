import http from 'http';
import PG from 'pg';

const port = Number(process.env.port);
const user = process.env.DATABASE_USER
const pass = process.env.DATABASE_PASSWORD
const host = process.env.DATABASE_URL
const db_port = process.env.DATABASE_PORT

let successfulConnection = false;

http.createServer(async (req, res) => {
  console.log(`Request: ${req.url}`);

  if (req.url === "/api") {
    const client = new PG.Client(`postgres://${user}:${pass}@${host}:${db_port}`);

    client.connect()
      .then(() => { successfulConnection = true })
      .catch(err => console.error('Database not connected -', err.stack));

    res.setHeader("Content-Type", "application/json");
    res.writeHead(200);

    let result;

    try {
      result = (await client.query("SELECT * FROM users")).rows[0];
    } catch (error) {
      console.error(error)
    }

    const data = {
      database: successfulConnection,
      userAdmin: result?.role === "admin"
    }

    res.end(JSON.stringify(data));
    
    client.end()
      .then(() => { successfulConnection = false })
      .catch(err => console.error('Database not disconnected -', err.stack));
  } else {
    res.writeHead(503);
    res.end("Internal Server Error");
  }

}).listen(port, () => {
  console.log(`Server is listening on port ${port}`);
});