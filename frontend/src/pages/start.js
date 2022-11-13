import * as React from "react"
import { Link } from "gatsby"

import Layout from "../components/layout"
import {Seo} from "../components/seo"

const Start = () => (
  <Layout>
    <div className="container text-center my-5">
      <h1> Start</h1>
      <p> To start the process and save enrgey upload the image of your floorplan here</p>
      <Link to="/">Go back to the homepage</Link>
    </div>
  </Layout>

)

export default Start



export const Head = () => (
    <Seo title="Start" />
)
