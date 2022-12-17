import * as React from "react"
import { Link } from "gatsby"
import { useState, useEffect} from 'react'
import { StaticImage } from "gatsby-plugin-image"


import Layout from "../components/layout"
import {Seo} from "../components/seo"


//https://stackoverflow.com/questions/38049966/get-image-preview-before-uploading-in-react+
export const Start = () => {
  const [selectedFile, setSelectedFile] = useState()
  const [preview, setPreview] = useState()

  // create a preview as a side effect, whenever selected file is changed
  useEffect(() => {
      if (!selectedFile) {
          setPreview(undefined)
          return
      }

      const objectUrl = URL.createObjectURL(selectedFile)
      setPreview(objectUrl)

      // free memory when ever this component is unmounted
      return () => URL.revokeObjectURL(objectUrl)
  }, [selectedFile])

  const onSelectFile = e => {
      if (!e.target.files || e.target.files.length === 0) {
          setSelectedFile(undefined)
          return
      }

      // I've kept this example simple by using the first image instead of multiple
      setSelectedFile(e.target.files[0])
  }

  return (
     <Layout>
    <div className="container text-center my-5">
      <h1> Start</h1>
      <p> To start the process and save energy, upload the image of your floorplan here.</p>
      
      <input className="form-control" type ="file" id="image-input" accept="image/jpeg, image/png, image/jpg"  onChange={onSelectFile}/>
      {selectedFile &&  <img src={preview} height={600} /> }
      <div className="row">
        <Link to="/statistics/" className="btn btn-primary my-2">Recognize my rooms</Link>
        <Link to="/" className="btn btn-secondary my-2">Home</Link>
      </div>
    </div>
  </Layout>
  )
}


export default Start

export const Head = () => (
    <Seo title="Start" />
)
 