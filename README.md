# Webcam image removal

This is a very simple script that I have written for a specific task I was required to do at work. It will take the images of a type of webcam and try to delete those that were taken during the dark. It's a very finicky script and may delete photos that wouldn't have to be deleted and it may not delete photos that would've had to be deleted. Deletion is done simply by extracting the date and time information and finding out the sunrise and sunset times of that date. As the camera may turn on its infrared mode (and hence produce black and white images) before then (in the case of sunset) or take a while longer to disable it during after sunrise, a value can be set that will offset the sunrise or sunset times by a certain number of minutes or hours. This way, more images will be deleted by the possibility of false positives is reduced greatly.

It has helped me greatly in reducing the time required for sorting over 50,000 images and I hope it will be helpful to you in some way.
Please do not expect a fully fledged-out program with tonnes of functionality; this is simply a very simple script that sort of does it job.

If you use this yourself, be sure to adjust the coördinates accordingly; there's tonnes of comments in the code, so you shouldn't miss it.

Also, you'll need to install the "suntimes" gem.
