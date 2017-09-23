name := "agency.parser"

version := "0.1"

scalaVersion := "2.12.3"

//mainClass in (Compile, run)  := Some("app.HypnosisAppJsonParser")
//mainClass in (Compile, run)  := Some("eeg.EpochFixer")
//mainClass in (Compile, run)  := Some("eeg.WinEEGReactionTimeExtractor")
//mainClass in (Compile, run)  := Some("eeg.PsychoPySubjectCleaner")
mainClass in (Compile, run)  := Some("eeg.PsychoPyGroupCleaner")

libraryDependencies += "org.json4s" %% "json4s-native" % "3.5.3"
libraryDependencies += "com.typesafe.akka" %% "akka-stream" % "2.5.4"