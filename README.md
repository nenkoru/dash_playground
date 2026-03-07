DASH playground
Generate sample FFmpeg video:

`ffmpeg -f lavfi -i testsrc=size=1280x720:rate=30 -t 30 -c:v libx264 -pix_fmt yuv420p test.mp4`

Generate multiple downsampled videos from it:
`ffmpeg -i test.mp4 -filter_complex "[0:v]split=3[v1][v2][v3]" -map "[v1]" -c:v:0 libx264 -b:v:0 800k -s:v:0 640x360 -map "[v2]" -c:v:1 libx264 -b:v:1 1500k -s:v:1 1280x720 -map "[v3]" -c:v:2 libx264 -b:v:2 3000k -s:v:2 1920x1080 -map 0:a\? -c:a aac -b:a 128k -use_timeline 1 -use_template 1 -adaptation_sets "id=0,streams=v id=1,streams=a" -seg_duration 4 -f dash stream.mpd`

Run simple http server using Python within the directory:
`python3 -m http.server 8080`


Test the stream using `http://localhost:8080/player.html`
Using chrome devtools throttle speed of the connection to simulate network congestion, see it automatically chooses which chunk to use based on the connection speed.
