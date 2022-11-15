import * as React from "react"
import { Link } from "gatsby"

import Layout from "../components/layout"
import {Seo} from "../components/seo"

const Start = () => (
  <Layout>
    <div className="container text-center my-5">
      <h1> Start</h1>
      <p> To start the process and save energy, upload the image of your floorplan here.</p>
      <div className="row">
        <Link to="/verification/" className="btn btn-primary my-2">Recognize my rooms</Link>
        <Link to="/" className="btn btn-secondary my-2">Home</Link>
      </div>
    </div>
  </Layout>
)

export default Start

export const Head = () => (
    <Seo title="Start" />
)
 