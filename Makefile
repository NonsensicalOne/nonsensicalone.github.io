build:
	hugo --minify

serve:
	rm -rf public/
	hugo serve --minify --noHTTPCache