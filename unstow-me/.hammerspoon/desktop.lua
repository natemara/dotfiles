local variables = require('variables')

local WALLPAPER_DIR = os.getenv("HOME") .. '/.wallpapers/'
local LOG = hs.logger.new('desktop')

local function buildPhotoPath(photoId)
	return WALLPAPER_DIR .. photoId .. '.jpg'
end

local function buildPhotoUrl(photoId)
	return 'file://' .. buildPhotoPath(photoId)
end

function setRandomBackground()
	function photoCallback(status, body, respHeaders)
		if status == 200 then
			photoPath = buildPhotoPath(photoId)
			file = io.open(photoPath, 'wb')
			if file == nil then
				hs.notify.show('Unsplash Error', 'Failed to open image file for writing', '')
			else
				file:write(body)
				file:close()

				screens = hs.screen.allScreens()
				photoUrl = buildPhotoUrl(photoId)
				for i, screen in ipairs(screens) do
					screen:desktopImageURL(photoUrl)
				end
				hs.notify.show(
					'Unsplash',
					'Set new background image',
					'On ' .. #screens .. ' screens - ' .. remainingRequests .. ' requests remaining this hour'
				)
			end
		else
			hs.notify.show('Unsplash Error', 'Got ' .. status .. ' back from unsplash', '')
		end
	end

	function photoDataCallback(status, body, respHeaders)
		if status == 200 then
			json = hs.json.decode(body)
			photo = json['urls']['full']
			photoId = json['id']
			remainingRequests = respHeaders['X-Ratelimit-Remaining']

			hs.http.asyncGet(photo, {}, photoCallback)
		else
			hs.notify.show('Unsplash Error', 'Got ' .. status .. ' back from unsplash', '')
		end
	end

	photoId = nil
	remainingRequests = nil

	headers = {}
	headers['Authorization'] = 'Client-ID ' .. variables.UNSPLASH_APPLICATION_ID

	hs.http.asyncGet(
		'https://api.unsplash.com/photos/random?orientation=landscape&featured=true',
		headers,
		photoDataCallback
	)
end

local function deletePicturesCallback(exitCode, stdout, stderr)
	LOG:d(
		'{"message": "delete-pictures", "exitCode": %d, "stdout": "%s", "stderr": "%s"}',
		exitCode,
		stdout,
		stderr
	)
end

function deleteDailyPictures()
	task = hs.task.new(
		'/usr/bin/find',
		deletePicturesCallback,
		function(_, _, _) return false end,
		{ WALLPAPER_DIR, '-atime', '+24h', '-delete', '-print' }
	)
end

hs.hotkey.bind({'cmd','alt','shift'}, 'D', setRandomBackground)
hs.timer.doEvery(hs.timer.hours(1), setRandomBackground)
hs.timer.doEvery(hs.timer.hours(24), deleteDailyPictures)
