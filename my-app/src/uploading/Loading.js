import './upload.css';
import './loader.css';

import {Button} from 'reactstrap';

function Loading(props) {
    const DB_NAME = 'CatImageLabels';
    const imageName = "catImage.jpg";

    const BASE_URL = process.env.REACT_APP_BASE_API_URL;
    const url = BASE_URL + "testing/getResults?file_name=" + imageName
    
    function poll() {
        fetch(url, {
            method: 'GET',
            headers: {
              "Access-Control-Allow-Origin": "*",
            },
          }).then(response => response.json())
          .then(data => {
            console.log(data);
            // subreddit;
            // accuracy;
          })
    }

    return (
        <div className="info">
            <div className="loader"></div>
            <br />
            <p>Processing your photo...</p>
            <Button className="button pollButton" onClick={() => poll()}>Poll</Button>
        </div>
        
    )
}

export default Loading;