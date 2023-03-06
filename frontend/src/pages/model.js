import * as React from "react"
import { Link } from "gatsby"
import { StaticImage } from "gatsby-plugin-image"

import Layout from "../components/layout"
import {Seo} from "../components/seo"


const Model = () => (
  <Layout>
    <div className="container text-center my-5">
      <h1> Result</h1>
      <p> Here is a simulation of your model!</p>
      <StaticImage
            src="../images/Model_results.png"
            width={500}
            quality={100}
            formats={["AUTO", "WEBP"]}
            alt="A Gatsby astronaut"
            className="img-fluid"
          />

      <div className="row">
        <Link to="/" className="btn btn-primary my-2">Home</Link>
      </div>
    </div>
  </Layout>

)

export default Model



export const Head = () => (
    <Seo title="Model" />
)

