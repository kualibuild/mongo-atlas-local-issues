import { MongoClient } from 'mongodb'

const client = await MongoClient.connect(
  'mongodb://localhost:27017?directConnection=true'
)

const Messages = client.db('test').collection('messages')

await Messages.insertOne({ text: 'Hello, MongoDB!' })

console.log(await Messages.find().toArray())

await client.close()
