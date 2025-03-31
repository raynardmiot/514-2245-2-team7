import './upload.css';
import UploadSection from './UploadSection';
import UploadModal from './UploadModal';
import React, {useState} from 'react';

function Upload() {
  const [altText, setAltText] = useState("White car");
  const [photo, setPhoto] = useState(undefined);
  
  console.log(process.env.REACT_APP_BASE_API_URL);

  return (
    <div className="surround">
        <div className="main">
            <UploadSection  photo={photo} altText={altText}/>
            <div className="info">
              <h1>r/WhiteCats</h1>
              <h3>Subreddit</h3>

              <br/>
              <h1>76.99%</h1>
              <h3>Accuracy</h3>

            </div>
        </div>
        <UploadModal setPhoto={setPhoto} photo={photo}/>
    </div>
    
  );
}

export default Upload;
