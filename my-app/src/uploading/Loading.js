import './upload.css';
import './loader.css';

function Loading(props) {

    return (
        <div className="info">
            <div className="loader"></div>
            <br />
            <p>Processing your photo...</p>
        </div>
        
    )
}

export default Loading;