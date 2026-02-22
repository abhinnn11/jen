const CDP = require('chrome-remote-interface');
const http = require('http');
const { spawn } = require('child_process');

const MODEL = process.argv[2];

function getTargets() {
  return new Promise((resolve, reject) => {
    http.get('http://127.0.0.1:9222/json', res => {
      let data = '';
      res.on('data', c => data += c);
      res.on('end', () => resolve(JSON.parse(data)));
    }).on('error', reject);
  });
}

(async () => {

  console.log("Searching for livestream tab...");

  let target;

  while (!target) {
    const targets = await getTargets();

    target = targets.find(t =>
      t.type === 'page' &&
      t.url.includes(`nnn/${MODEL}`)
    );

    if (!target) {
      console.log("Tab not ready yet... waiting");
      await new Promise(r => setTimeout(r, 5000));
    }
  }

  console.log("Found tab:", target.url);

  const client = await CDP({ target: target.webSocketDebuggerUrl });
  const { Page } = client;

  await Page.enable();

const filename = `${MODEL}_${Date.now()}.mp4`;

const ffmpeg = spawn('ffmpeg', [
  '-y',
  '-f', 'image2pipe',
  '-vcodec', 'mjpeg',
  '-r', '30',
  '-i', '-',

  // *** THE IMPORTANT PART ***
  '-vf', 'pad=ceil(iw/2)*2:ceil(ih/2)*2',

  '-c:v', 'libx264',
  '-preset', 'veryfast',
  '-pix_fmt', 'yuv420p',
  '-crf', '23',

  filename
]);

  ffmpeg.stderr.on('data', d => process.stderr.write(d));

  Page.screencastFrame(async ({ data, sessionId }) => {
    ffmpeg.stdin.write(Buffer.from(data, 'base64'));
    await Page.screencastFrameAck({ sessionId });
  });

  await Page.startScreencast({
    format: 'jpeg',
    quality: 80,
    maxWidth: 1280,
    maxHeight: 720,
    everyNthFrame: 1
  });

})();
