import './upload.css';
import UploadSection from './UploadSection';
import UploadModal from './UploadModal';
import React, { useState } from 'react';
import Loading from './Loading';

function Upload() {
  const [altText, setAltText] = useState("White car");
  const [photo, setPhoto] = useState(undefined);

  const [subreddit, setSubreddit] = useState(undefined);
  const [accuracy, setAccuracy] = useState(undefined);

  const [loading, setLoading] = useState(false);

  const BASE_URL = process.env.REACT_APP_BASE_API_URL;
  console.log(process.env.REACT_APP_BASE_API_URL); // Environment Variable for API URL

  function getS3 () {
    var s3URL;
    var imageId;
    fetch(BASE_URL)
      .then(response => response.json())
      .then(data => {
        s3URL = data.url;
        imageId = data.imageId;
      });
    
    setLoading(true);
    postImage(s3URL, imageId);
  }

  async function postImage(url, imageId) {
    await fetch(url, {
      method: 'PUT',
      headers: {
        'Content-type': 'multipart/form-data'
      },
      body: photo // Check if works
    })
      .then(response => response.json())
      .then(data => {
        // TO DO!
        // Unsure what the api returns :<

        // subreddit;
        // accuracy;
      })

    setLoading(true);
  }

  function loadRight() {
    if (loading) {
      return <Loading />
    }
    else {
      return (
        <>
          <h1>r/{subreddit != undefined ? subreddit : "WhiteCats" }</h1>
          <h3>Subreddit</h3>

          <br />
          <h1>{accuracy != undefined ? accuracy : "76.77"}%</h1>
          <h3>Accuracy</h3>
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
      <UploadModal setPhoto={setPhoto} photo={photo} />
    </div>

  );
}

export default Upload;
