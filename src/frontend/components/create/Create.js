import { useState } from 'react';
import { Form } from 'react-bootstrap';

export default function Create() {
  const [selectedFile, setSelectedFile] = useState(null);

  const handleFileChange = (event) => {
    setSelectedFile(event.target.files[0]);
  };

  return (
    <div className="m-4 flex flex-col justify-center items-center">
      <div className="grid grid-row-4 gap-10 text-black bg-gray-300 p-10 rounded-lg" style={{ width: '35%' }}>
        <div >
          <label htmlFor="fileInput" className="file-input-label  border border-gray-300 rounded cursor-pointer px-4 py-2 bg-pink-400 hover:bg-pink-700 text-white">
            <span>Choose file</span>
            <Form.Control
              id="fileInput"
              type="file"
              accept=".jpg, .jpeg, .png"
              onChange={handleFileChange}
              className="hidden"
            />
          </label>
          {selectedFile && <p className='mt-2'>Selected file: {selectedFile.name}</p>}
        </div>
        <div className="rounded">
          <Form.Control required type="text" placeholder="Name" className="w-full rounded-sm" />
        </div>
        <div className="">
          <Form.Control required as="textarea" placeholder="Description" className="w-full rounded-sm" />
        </div>
        <div className="">
          <Form.Control required type="number" placeholder="Price in ETH" className="w-full rounded-sm" />
        </div>
      </div>
      <div className='mt-4'>
      <button className=" link rounded-full">Create & List NFT</button>
      <button className="link rounded-full ml-4">Clear</button>
      </div>
    </div>
  );
}
