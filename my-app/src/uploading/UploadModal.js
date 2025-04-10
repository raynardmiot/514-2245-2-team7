import 'bootstrap/dist/css/bootstrap.min.css';
import './upload.css';

import React, {useState} from 'react';
import { Modal, ModalHeader, ModalBody, Button, ModalFooter } from 'reactstrap';

function UploadModal(props) {
    const [modal, setModal] = useState(props.modal);
    const toggle = () => {
        if(!modal)
            setWarning(false);
        setModal(!modal)
    };
    var file = undefined;
    const [warning, setWarning] = useState(false);
    const [wrongFileType, setWrongFileType] = useState(false);


    var reader = new FileReader();
    function onFileUpload(event) {
        if(event.target.files && event.target.files[0]) {
            file = event.target.files[0];
        }
    }

    function checkFileType(file) {
        const ext = file.name.split(".")[1];
        switch (ext.toLowerCase()) {
            case 'jpg':
            case 'jpeg':
                setWrongFileType(false);
                return true;
        }
        setWrongFileType(true);
        return false;
    }

    function onUpload() {
        if(file != undefined) {
            if (checkFileType(file)) {
                var reader = new FileReader();
                reader.onload = function (e) {
                    props.setPhoto(e.target.result); 
                    // add api call to s3
                    props.getS3();
                };
                reader.readAsDataURL(file);
                toggle();
            }
        }
        else {
            setWarning(true);
        }
    }

    return (
        <>
            <Button className="button"onClick={() => toggle()}>Upload</Button>
            <Modal isOpen={modal} toggle={toggle}>
                <ModalHeader toggle={toggle}>
                    Upload Photo
                </ModalHeader>
                <ModalBody>
                <input onChange={(event) => onFileUpload(event)}type="file" id="input" />
                <p className="warningText" style={{"display": (warning ? "inherit" : "none")}}>Please select a photo!</p>
                <p className="warningText" style={{"display": (wrongFileType ? "inherit" : "none")}}>Please submit a .jpeg photo</p>
                </ModalBody>
                <ModalFooter>
                    <Button className="button uploadButton" onClick={() => onUpload()}>Upload</Button>
                    <Button className="button cancelButton">Cancel</Button>
                </ModalFooter>
            </Modal>
        </>
        
    )
}

export default UploadModal;