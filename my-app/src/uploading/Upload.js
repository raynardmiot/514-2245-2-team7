import './upload.css';
import UploadSection from './UploadSection';
import UploadModal from './UploadModal';
import React, { useState } from 'react';
import {Button} from 'reactstrap';
import Loading from './Loading';

function Upload() {
  const [altText, setAltText] = useState("White car");
  const [photo, setPhoto] = useState(undefined);

  const [jpegPhoto, setJPEGphoto] = useState(undefined);

  const [subreddit, setSubreddit] = useState(undefined);
  const [accuracy, setAccuracy] = useState(undefined);

  const [loading, setLoading] = useState(false);
  const [extension, setExtension] = useState(undefined);

  const BASE_URL = process.env.REACT_APP_BASE_API_URL;
  console.log(process.env.REACT_APP_BASE_API_URL); // Environment Variable for API URL

  function getS3() {
    var s3URL;
    var imageId;
    console.log("Running getS3");

    const url = BASE_URL + "testing/uploadImage";
    console.log(url);
    fetch(url)
      .then(response => response.json())
      .then(data => {
        console.log(data);
        console.log(data.url);
        console.log(data['url']);
        s3URL = data.url;
        imageId = data.imageId;
      }).then(() => {
        setLoading(true);
        postImage(s3URL, imageId); // Call S3 
      });

  }

  function postImage(url, imageId) {
    console.log("Running postImage");
    // console.log(jpegPhoto);
    // console.log(photo);
    console.log(url);
    fetch(url, {
      method: 'PUT',
      headers: {
        "Access-Control-Allow-Origin": "*",
        'Content-type': 'image/' + extension
      },
      body: photo // Check if works
    }).then(() => {
      let pollingURL;
      if(extension == 'jpeg') {
        pollingURL = BASE_URL + "testing/getResults?file_name=" + imageId + '.jpg'; // for some reason jpeg gets converted to jpg
      }
      else {
        pollingURL = BASE_URL + "testing/getResults?file_name=" + imageId + '.' + extension;
      }
      poll(pollingURL);
    })
      .catch((reason) => {
        console.log("postImage", reason);
      })

    setLoading(true);
  }

  const imageName = "catImage.jpg";

  
  function poll(pollingURL) {
      console.log(pollingURL);
      fetch(pollingURL)
        .then(response => {
          if (response.ok) {
            return response.json()
          } else if (response.status === 404) {
            throw new Error("Item not found"); // Handle 404 case
          } else {
            throw new Error(`HTTP error! Status: ${response.status}`); // Handle other errors
          }
        })
        .then(data => {
          console.log(data);
          
          setLoading(false);
          setAccuracy(data.label.confidence.toFixed(2));
          setSubreddit(data.label.name);
        })      
        .catch((error) => {
          console.log("retrieveImage", error.message);
          if(error.message == "Item not found") { // 404 case
            setTimeout(poll(pollingURL), 500);
          }
        })
  }

  function loadRight() {
    if (loading) {
      var myInterval = setInterval(poll, 5000);

      return <Loading />
    }
    else {
      return (
        <>
          <h1>r/{subreddit != undefined ? subreddit : "WhiteCats"}</h1>
          <h3>Subreddit</h3>

          <br />
          <h1>{accuracy != undefined ? accuracy : "76.77"}%</h1>
          <h3>Accuracy</h3>
          <Button className="button pollButton" onClick={() => poll()}>Poll</Button>
        </>

      )
    }
  }


  return (
    <div className="surround">
      <div className="main">
        <UploadSection photo={photo} altText={altText} />
        <div className="info">
          {loadRight()}
        </div>

      </div>
      <UploadModal setExtension={setExtension} setJPEGphoto={setJPEGphoto} getS3={getS3} setPhoto={setPhoto} photo={photo} />
    </div>

  );
}

export default Upload;
