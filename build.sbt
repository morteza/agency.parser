name := "onto.hypnosis.parser"

version := "0.1"

scalaVersion := "2.12.3"

mainClass := Some("eeg.EpochFixer")

libraryDependencies += "org.json4s" %% "json4s-native" % "3.5.3"
libraryDependencies += "com.typesafe.akka" %% "akka-stream" % "2.5.4"