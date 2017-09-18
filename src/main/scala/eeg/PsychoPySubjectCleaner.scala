package eeg

import java.nio.charset.StandardCharsets
import java.nio.file.{Files, Paths}

import org.json4s.scalap.scalasig.StringBytesPair

import scala.collection.mutable
import scala.collection.mutable.ListBuffer
import scala.io.{Source => IOSource}

object PsychoPySubjectCleaner extends PsychoPySubjectCleaner {

  def main(args: Array[String]): Unit = {
    if (args.length!=1)
      System.exit(1)

    val subject = Option(args(0))

    val homeDir = System.getProperty("user.home")
    //val path = Option(s"/Users/morteza/Desktop/data/${subject.get}/${subject.get}_practice.csv")
    val path = Option(s"${homeDir}/Desktop/data/${subject.get}/${subject.get}.csv")

    val (conditions, conditionsInRows) = analyseSubject(subject.get, path.get, "hyp", true)

    val conditionsInRowsWithHeader = "subject, group, condition, rt\n" + conditionsInRows

    PsychoPySubjectCleaner.writeToFile(path.get.substring(0, path.get.length-4) + "_conditions.csv", conditions)
    PsychoPySubjectCleaner.writeToFile(path.get.substring(0, path.get.length-4) + "_conditions_rows.csv", conditionsInRowsWithHeader)
    //TODO later we need to transpose columns<->rows using Excel/Numbers
  }
}
/**
  * To clean and prepare RT/Correctness data provided by PsychoPy Agency Task
  */
class PsychoPySubjectCleaner {


  def analyseSubject(subject: String, path: String, group: String = "hyp", includeOnlyCorrectResponses: Boolean = true): (String, String) = {
    val rows = loadFile(path).split("\n")

    //TODO create lists for each condition
    // Results map: Key=Condition, Value= List of RTs for that condition
    val conditions = mutable.Map[String, mutable.ListBuffer[Double]]()
    //TODO convert into Enumeration
    conditions.put("exp_cor", ListBuffer[Double]()) // Explicit Correct
    conditions.put("exp_inc", ListBuffer[Double]()) // Explicit Incorrect
    conditions.put("imp_cor", ListBuffer[Double]()) // Implicit Correct
    conditions.put("imp_inc", ListBuffer[Double]()) // Implicit Incorrect
    conditions.put("fre_exp", ListBuffer[Double]()) // Explicit Free
    conditions.put("fre_ctl", ListBuffer[Double]()) // Control Free
    conditions.put("unknown", ListBuffer[Double]()) // Control Free

    var trialsInRowsCsv = StringBuilder.newBuilder
    //trialsInRowsCsv append "subject, group, condition, rt\n"

    //1. iterate over rows and extract interesting data
    //2. for each row check correctness
    //3. for each condition put the RT into the appropriate list
    rows
      .drop(1)
      // split into fields
      .map(row => row.split(","))
      // remove the rest
      .filter(fields => fields.length==12)
      // extract data
      .map(fields => {
      var response = fields(7)
      response = if (response.length>2) response.trim.toLowerCase.substring(1, fields(7).trim.length - 1) else ""
      val group = fields(0).trim.toInt
      val rt = if (fields(8).trim.length>0) fields(8).trim.toDouble else 0.0
      // interested in these fields: group (0), agency_level (2), condition (4), response (7), rt (8), order (11)
      // (Int, String, Int, String, Double, Int, Boolean)
      ( group,
        fields(2).trim,
        fields(4).trim.toInt,
        response,
        rt,
        fields(11).trim.toInt,
        isCorrect(group, response))
    })
      // TODO to remove those unanswered fields (RT="") or just do something else?
      .filter (fields => fields._5>0.0)
      // put into the corrsponding list of RTs
      .map(fields => {
      var condition = ""
      (fields._1,fields._7) match {
        case (1, true) | (5, true) => { condition = "exp_cor" }
        case (1, false) | (5, false) => { condition = "exp_inc" }
        case (4, _) => { condition = "fre_ctl" }
        case (3, _) => { condition = "fre_exp" }
        case (2, true) | (6, true) => { condition = "imp_cor" }
        case (2, false) | (6, false) => { condition = "imp_inc" }
        case something => {println (s"Unknown condition: $something"); condition = "unknown"}
      }
      conditions(condition) += fields._5
      // Append to row-based trial csv if subject response is correct
      if (fields._7) trialsInRowsCsv append s"$subject, $group, $condition, ${fields._5.toString}\n"
    })

    //TODO write lists as csv rows
    var sb = StringBuilder.newBuilder
    conditions foreach { cond =>
      sb append cond._1 append "," // write condition name
      sb append cond._2.mkString(",") append "\n"
    }

    (sb.mkString, trialsInRowsCsv.mkString)
  }

  /**
    * Load file as string.
    * @param path
    * @return
    */
  def loadFile(path: String): String = {
    IOSource.fromFile(path, "UTF-8").mkString
  }

  def writeToFile(path: String, str: String) = {
    Files.write(Paths.get(path), str.getBytes(StandardCharsets.UTF_8))
  }

  /**
    * Checks if subject's respond is correct accoring to the expected key.
    * @param group
    * @param response
    * @return
    */
  def isCorrect(group: Int, response: String) = (group, response) match {
    case (5, "right") => false  // explicit
    case (1, "left") => false   // explicit
    case (6, "right") => false  // implicit
    case (2, "left") => false   // implicit
    case (1, "") | (2, "") | (5, "") | (6, "") => false
    case _ => true
  }
}