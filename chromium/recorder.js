const CDP = require('chrome-remote-interface');
const { spawn } = require('child_process');

(async () => {

  const client = await CDP({
    target: 'ws://127.0.0.1:9222/devtools/page/35C6BF94D57EED587AA421F410834A2D'
  });

  const { Page } = client;

  await Page.enable();

  // start ffmpeg
  const ffmpeg = spawn('ffmpeg', [
    '-y',
    '-f', 'image2pipe',
    '-vcodec', 'mjpeg',
    '-r', '30',
    '-i', '-',
    '-c:v', 'libx264',
    '-preset', 'veryfast',
    '-pix_fmt', 'yuv420p',
    '-crf', '23',
    'output.mp4'
  ]);

  ffmpeg.stderr.on('data', d => process.stderr.write(d));

  Page.screencastFrame(async ({ data, sessionId }) => {
    const buffer = Buffer.from(data, 'base64');
    ffmpeg.stdin.write(buffer);
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
