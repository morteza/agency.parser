package eeg

import java.nio.charset.StandardCharsets
import java.nio.file.{Files, Paths}

import scala.collection.mutable
import scala.collection.mutable.ListBuffer
import scala.io.{Source => IOSource}

/**
  * To generate a single file,
  */
object TrialsOrderGenerator extends App {

  val homeDir = System.getProperty("user.home")

  val removePractice = false

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

  val offset = if (removePractice) 1 else 1 // The csv files does not contain practice. So it's always 1

  subjects foreach { s =>
    val path = s"$homeDir/Desktop/data/${s._1}/${s._1}.csv"
    var result = StringBuilder.newBuilder
    result append "Group\n"

    //val practice = loadFile(path).split("\n").drop(1).take(20)
    val trials = loadFile(path).split("\n").toList

    println(s"# of trials for ${s._1}: ${trials.length}")

    val block1 = sortByOrder(trials.slice(offset      , offset + 78))
    val block2 = sortByOrder(trials.slice(offset + 78 , offset + 156))
    val block3 = sortByOrder(trials.slice(offset + 156, 236))

    if (!removePractice) for (i <- 1 to 20) result append "7\n" // Practice group is 7
    extractGroups(block1).map(grp => result append s"$grp\n")
    extractGroups(block2).map(grp => result append s"$grp\n")
    extractGroups(block3).map(grp => result append s"$grp\n")
    writeToFile(s"$homeDir/Desktop/data/${s._1}/${s._1}_trial_orders.csv", result.mkString)
  }

  def writeToFile(path: String, str: String) = {
    Files.write(Paths.get(path), str.getBytes(StandardCharsets.UTF_8))
  }

  def loadFile(path: String): String = {
    IOSource.fromFile(path, "UTF-8").mkString
  }

  def sortByOrder(block: List[String], orderColumnIndex: Int = 11): List[String] = {
    block.sortBy(row => row.split(",")(orderColumnIndex).trim.toInt)
  }

  def extractGroups(block: List[String]): List[Int] = {
    block
      .map(_.split(","))
      .map(fields => {
        var response = fields(7)
        response = if (response.length>2) response.trim.toLowerCase.substring(1, fields(7).trim.length - 1) else ""

        mapGroup(fields(0).trim.toInt, response)
      })
  }

  /**
    * Group according to our EEGLAB Study design.
    * 7 is prct: practice
    * 0 is wrng: wrong answer
    * 1 is expl: explicit
    * 2 is impl: implicit
    * 3 is exfr: forced choice (explicit free)
    * 4 is ctrl: control
    * @param originalGroup
    * @param response
    * @return
    */
  def mapGroup(originalGroup: Int, response: String) = (originalGroup, response) match {
    case (5, "right") => 0  // wrong explicit
    case (1, "left") => 0   // wrong explicit
    case (6, "right") => 0  // wrong implicit
    case (2, "left") => 0   // wron implicit
    case (1, "") | (2, "") | (3, "") | (5, "") | (6, "") => 0
    case (5, "left") => 1
    case (6, "left") => 2
    case _ => originalGroup
  }
}