DASH playground
Generate sample 4k video FFmpeg video:

`ffmpeg -f lavfi -i testsrc=size=3840x2160:rate=60 -t 30 -c:v libx264 -pix_fmt yuv420p test.mp4`

Generate multiple downsampled videos from it with mpd:

`./downscale_video.sh test.mp4`


Run simple http server using Python within the directory:

`python3 -m http.server 8080`


Test the stream using `http://localhost:8080/player.html`
Using chrome devtools throttle speed of the connection to simulate network congestion, see it automatically chooses which chunk to use based on the connection speed.
