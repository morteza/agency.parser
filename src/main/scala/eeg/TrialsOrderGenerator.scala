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
  val erp = true // Uses coding for ERP (shows both stimulus and response)

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

    result.append(if (erp) "Event\n" else "Group\n")

    //val practice = loadFile(path).split("\n").drop(1).take(20)
    val trials = loadFile(path).split("\n").toList

    println(s"# of trials for ${s._1}: ${trials.length}")

    val block1 = sortByOrder(trials.slice(offset      , offset + 78))
    val block2 = sortByOrder(trials.slice(offset + 78 , offset + 156))
    val block3 = sortByOrder(trials.slice(offset + 156, 236))

    if (erp && !removePractice)
      for (i <- 1 to 20) result append "10\n11\n" //ERP coding of practice (10 followed by an 11).

    if ((!erp) && !removePractice)
      for (i <- 1 to 20) result append "practice\n" // EEG coding of practice

    extractEvents(block1, erp).map(grp => result append s"$grp\n")
    extractEvents(block2, erp).map(grp => result append s"$grp\n")
    extractEvents(block3, erp).map(grp => result append s"$grp\n")

    if (erp)
      writeToFile(s"$homeDir/Desktop/data/${s._1}/${s._1}_erp_trial_orders.csv", result.mkString)
    else
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

  def extractEvents(block: List[String], erp: Boolean): List[String] = {
    block
      .map(_.split(","))
      .map(fields => {
        var response = fields(7)
        response = if (response.length>2) response.trim.toLowerCase.substring(1, fields(7).trim.length - 1) else ""
        if (erp)
          mapERPGroup(fields(0).trim.toInt, response).replace(",","\n") // This to convert rows to two columns
        else
          mapGroup(fields(0).trim.toInt, response)
      })
  }

  /**
    * Events according to our ERPLAB Study design:
    * 9: Incorrect
    * 8: Correct
    * 1: Implicit Left
    * 2: Implicit Right
    * 3: Explicit Left
    * 4: Explicit Right
    * 5: Free
    * 6: Control
    * 10: Practice Onset
    * 11: Practice RT
    * 12: Timeout
    * @param originalGroup
    * @param response in (eventCode,responseCode) format.
    * @return
    */
  def mapERPGroup(originalGroup: Int, response: String) = (originalGroup, response) match {
    case (1, "") => "4,9"              // [Explicit, Right]: Wrong
    case (2, "") => "2,9"              // [Implicit, Right]: Wrong
    case (3, "") => "5,9 "             // [Free    , R/L  ]: Wrong
    case (5, "") => "3,9"              // [Explicit, Left ]: Wrong
    case (6, "") => "1,9"              // [Implicit, Left ]: Wrong

    case (1, "left") => "4,9"          // [Explicit, Right]: Wrong
    case (2, "left") => "2,9"          // [Implicit, Right]: Wrong
    case (5, "right") => "3,9"         // [Explicit, Left ]: Wrong
    case (6, "right") => "1,9"         // [Implicit, Left ]: Wrong

    case (1, "right") => "4,8"         // [Explicit, Right]: Correct
    case (2, "right")=> "2,8"          // [Implicit, Right]: Correct
    case (3, "left") => "5,8"          // [Free    , R/L  ]: Correct
    case (3, "right") => "5,8"         // [Free    , R/L  ]: Correct
    case (5, "left") => "3,8"          // [Explicit, Left ]: Correct
    case (6, "left") => "1,8"          // [Implicit, Left ]: Correct
    case (4, _) => "6,8"               // [Control , ...  ]: Correct

    case _ => "0,9"                    // [    Unknown    ]: Wrong
  }

  /**
    * Group according to our EEGLAB Study design.
    * @param originalGroup
    * @param response
    * @return
    */
  def mapGroup(originalGroup: Int, response: String) = (originalGroup, response) match {
    case (1, "") | (2, "") | (3, "") | (5, "") | (6, "") => "incorrect"
    case (5, "right") => "incorrect"  // wrong explicit
    case (1, "left") => "incorrect"   // wrong explicit
    case (6, "right") => "incorrect"  // wrong implicit
    case (2, "left") => "incorrect"   // wron implicit
    case (5, "left") | (1, "right") => "explicit"
    case (6, "left") | (2, "right")=> "implicit"
    case (4, _) => "control"
    case (3, _) => "free"
    case _ => "invalid"
  }
}