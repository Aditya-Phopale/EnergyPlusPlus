import * as React from "react"
import { Link } from "gatsby"
import { StaticImage } from "gatsby-plugin-image"

import Layout from "../components/layout"
import { Seo } from "../components/seo"

const IndexPage = () => (
  <Layout>
    <section className="py-5 text-center container">
      <div className="row py-lg-5">
        <div className="col-lg-6 col-md-8 mx-auto">
          <h1 className="fw-light">Energy++ </h1>
          <p className="lead text-muted"> Better future. For everyone.</p>
          <StaticImage
            src="../images/icon.png"
            width={300}
            quality={95}
            formats={["AUTO", "WEBP"]}
            alt="A Gatsby astronaut"
            className="img-fluid"
          />

        </div>
      </div>
      <div className="row">
        <Link to="/start/" className="btn btn-primary my-2">Start</Link>
        <Link to="/about/" className="btn btn-secondary my-2">About</Link>
      </div>
    </section>
  </Layout>
)

export default IndexPage

export const Head = () => (
    <Seo />
)