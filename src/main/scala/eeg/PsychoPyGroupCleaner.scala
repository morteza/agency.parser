package eeg

import java.nio.charset.StandardCharsets
import java.nio.file.{Files, Paths}

import scala.collection.mutable
import scala.collection.mutable.ListBuffer
import scala.io.{Source => IOSource}

/**
  * To clean and prepare RT/Correctness data provided by PsychoPy Agency Task
  */
object PsychoPyGroupCleaner extends App {

  val homeDir = System.getProperty("user.home")

  val subjectClearner = new PsychoPySubjectCleaner()
  val subjects = Map (
    "ach" -> "nonhyp",
    "aka" -> "hyp",
    "akh" -> "hyp",
    "bah" -> "nonhyp",
    "fhe" -> "hyp",
    "mhe" -> "nonhyp",
    "mkh" -> "hyp",
    "nkh" -> "hyp",
    "nsh" -> "hyp",
    "rho" -> "hyp",
    "rsa" -> "hyp",
    "sa1" -> "hyp",
    "sa2" -> "hyp",
    "sfa" -> "hyp",
    "sja" -> "hyp",
  )


  val allSubjectsRows = StringBuilder.newBuilder
  allSubjectsRows append "subject,group,condition,rt\n"
  subjects foreach { s =>
    val path = s"${homeDir}/Desktop/data/${s._1}/${s._1}.csv"
    val (conditions, conditionsInRows) = subjectClearner.analyseSubject(s._1, path, s._2, true)
    subjectClearner.writeToFile(path.substring(0, path.length-4) + "_conditions.csv", conditions)
    subjectClearner.writeToFile(path.substring(0, path.length-4) + "_conditions_rows.csv", conditionsInRows)
    //TODO later we need to transpose columns<->rows using Excel/Numbers
    allSubjectsRows append s"$conditionsInRows"
  }

  subjectClearner.writeToFile(s"${homeDir}/Desktop/data/conditions_rows.csv", allSubjectsRows.mkString)

}