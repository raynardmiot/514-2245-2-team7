import './upload.css';
import './loader.css';

function Loading(props) {

    return (
        <div className="infoContainer">
            <div className="info">
                <div className="loader"></div>
                <br />
                <p>Processing your photo...</p>
            </div>
        </div>
        
        
    )
}

export default Loading;