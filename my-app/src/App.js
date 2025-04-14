import './App.css';
import './uploading/upload.css';
import UploadModal from './uploading/UploadModal';
import React, { useState } from 'react';
import Upload from './uploading/Upload.js';

function App() {
  const [main, setMain] = useState(true);

  function renderMain() {
    return (
      <div className="surround">
        <div className="center block">
          <p className="welcome">Welcome to</p>
          <p className="title">CaSSyDi</p>
          <p className="subtitle">Cat Subreddit System of Distribution</p>
        </div>
        <UploadModal setMain={setMain}/>
      </div>
    );
  }

  return (
    <>
      {main ? renderMain() : <Upload setMain={setMain}/>}
    </>
    
  )

  
}

export default App;
