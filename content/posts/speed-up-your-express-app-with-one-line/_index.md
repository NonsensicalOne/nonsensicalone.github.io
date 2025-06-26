+++
date = '2025-06-25T22:58:27+03:00'
draft = false
title = 'Speed Up Your Express App With One Line'
+++

If you've worked a bit with NodeJS, you've probably heard of Express. The web framework that is slow but has good syntax (a matter of personal preference). In this tutorial I will show you how to make your Express application at least 3 times faster

Requirements:
1. An application written with Express.js (OBV)

Let's say your express application is this
```js
const express = require('express')
const app = express()
const port = 3000

app.get('/', (req, res) => {
  res.send('Hello World!')
})

app.listen(port, () => {
 console.log(`Example app listening on port ${port}`)
})
```

First install a package called ultimate-express which is a faster implementation of Express and they claim to be at least 3 times more faster than Express.
```
npm install ultimate-express
```

Oh by the way, ultimate-express may not work with [every single express app](https://github.com/dimdenGD/ultimate-express?tab=readme-ov-file#differences-from-express). Also it doesn't work with Vercel serverless functions thingy, I tried it myself.

Anyways, after installing the ultimate-express package replace this link
```js
const express = require('express')
```

With this:
```js
const express = require('ultimate-express')
```

And then uninstall express to make node_modules less bloated:
```
npm uninstall express
```

Now your Express app is now super duper fast and can even beat the shit out of [Elysia](/posts/speed-up-your-express-app-with-one-line/image.webp), have a good day and see you in my next blog post
