import './upload.css';
import UploadSection from './UploadSection';
import UploadModal from './UploadModal';
import React, { useState } from 'react';
import {Button} from 'reactstrap';
import Loading from './Loading';

function Upload(props) {
  const [altText, setAltText] = useState("White car");
  const [photo, setPhoto] = useState(undefined);

  var varPhoto = undefined; 

  const [results, setResults] = useState([{Name: "whitecat", Confidence: 78.77},{Name: "whitecats", Confidence: 98.77}])
  const [loading, setLoading] = useState(false);

  const BASE_URL = process.env.REACT_APP_BASE_API_URL;
  console.log(process.env.REACT_APP_BASE_API_URL); // Environment Variable for API URL

  function getS3() {
    console.log("Running getS3");
    
    setLoading(true);

    const url = BASE_URL + "testing/uploadImage/";
    console.log(varPhoto.substring(23));
    fetch(url, {
      method: "PUT",
      headers: {
        'Content-type': 'text/plain',
      },
      body: varPhoto.substring(23)
    })
      .then(response => response.json())
      .then(data => {
        console.log(data);
        console.log(data.filename);
        console.log(data['filename']);
        const imageId = data.filename;

        let pollingURL = BASE_URL + "testing/getResults/?file_name=" + imageId;
        poll(pollingURL);
      })
      .catch((reason) => {
        console.log("postImage", reason);
      });

  }

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
          setResults(data.Labels);
        })      
        .catch((error) => {
          console.log("retrieveImage", error.message);
          if(error.message == "Item not found") { // 404 case
            setTimeout(() => poll(pollingURL), 2500);
          }
        })
  }

  function loadResults() {
    var rendered = [];
    for (let result of results) {
      rendered.push(<div className="info">
        <div>
          <h1>r/{result.Name}</h1>
          <h3>Subreddit</h3>
        </div>
        
        <div>
          <h1>{result.Confidence.toFixed(2)}%</h1>
          <h3>Accuracy</h3>
        </div>
      </div>)
    }
    return rendered;
  }

  function loadRight() {
    if (loading) {
      return <Loading />
    }
    else {
      return (
        <div className="infoContainer">
          {loadResults()}
        </div>
      )
    }
  }

  function uploadingPhoto(photo) {
    varPhoto = photo;
    setPhoto(photo);
  }


  return (
    <div className="surround">
      <div className="main">
        <UploadSection photo={photo} altText={altText} />
        <div className="center">
          {loadRight()}
        </div>

      </div>{
        loading ? "" :
        <UploadModal setMain={props.setMain}getS3={getS3} setPhoto={uploadingPhoto} photo={photo} />
      }
    </div>

  );
}

export default Upload;
