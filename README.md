# Recaptur: Scan & Edit Metadat‪a‬

![](https://github.com/jason-ono/Story/blob/master/recaptur_assets/small.png?raw=true)

 Pers. Correction                     |  Date Input                | Map View  | Result on Photos
:-------------------------:|:-------------------------:|:-------------------------:|:-------------------------:
 ![](https://github.com/jason-ono/Story/blob/master/recaptur_assets/pC%20(4).gif?raw=true) |  ![](https://github.com/jason-ono/Story/blob/master/recaptur_assets/date%20(1).gif?raw=true)  |  ![](https://github.com/jason-ono/Story/blob/master/recaptur_assets/sydney.gif?raw=true) | ![](https://github.com/jason-ono/Story/blob/master/recaptur_assets/result.gif?raw=true) 

***Now available on [App Store for free](https://apps.apple.com/us/app/recaptur-scan-edit-metadata/id1559885464)!***

Recaptur is an iOS app that allows you to
1. Scan physical photos with **real-time rectangle detection** & **perspective correction**
2. Save the image with **user-selected timestamp** and **location data**

## Background

There are tons of apps today that allow you to scan physical photos with optimized rectangle detection and perspective correction. 

But I always wished if there were a way to **capture the old photos I have with original date** and **location data**, as though I had a smartphone back when I took those pictures—so **I created just that!**

Through this app, you can **scan a photo**, then **save it with the date and location of your choice**. 

After you saved your photo, you should be able to see all the changes reflected in Photos app.

## How it works

I created this app **without using the Interface Builder**. All features have been implemented **programmatically**.

The bulk of AV-related methods in this project comes from **AVFoundation** framework. 

The app has a Snapchat-like **full-screen camera**. The app displays **real-time rectangle detection** while the camera is on, and **perspective correction** is applied on the extracted image as soon as the shutter is pressed.

[**Anupam Chugh**](https://heartbeat.fritz.ai/scanning-credit-cards-with-computer-vision-on-ios-c3f4d8912de4) wrote a great article on developing Swift credit card scanner app, so I based off of his code when implementing rectangle detection and perspective correction. 

The processed image gets exported to the editor screen as an **UIImage** object. In the editor screen, user saves a location data as a **CLLocation** object through **MKMapView**. The timestamp is saved as a **Date** object through **UIDatePicker**.

Lastly, the image data is saved to the Photo Library through **UIImageWriteToSavedPhotosAlbum** method. Immediately after, **PHAssetChangeRequest** fetches the newest photo in the album, and overwrites the metadata with user-provided timestamp and location data.


## License

[MIT](https://choosealicense.com/licenses/mit/)
