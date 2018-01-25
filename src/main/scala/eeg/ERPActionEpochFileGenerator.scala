package eeg

import java.nio.charset.StandardCharsets
import java.nio.file.{Files, Paths}
import java.util.Scanner

import scala.collection.mutable
import scala.io.{Source => IOSource}

/**
  * To fix WinEEG/PsychoPy labels, and prepare epoch files for ERPLAB
  */
object ERPActionEpochFileGenerator extends App {

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

  subjects.foreach{s => createSubjectEpochs(s._1, System.getProperty("user.home")+"/Desktop/data")}

  def createSubjectEpochs(subject: String, rootDir: String): Unit = {
    if (subject == null || subject.trim.length!=3)
      return

    println(s"Generating ERP epoch file for $subject")
    val removePractice = true

    val path = Option(s"${rootDir}/${subject}/${subject}_labels.txt")
    val trialsPath = Option(s"${rootDir}/${subject}/${subject}_erp_trial_orders.csv")

    val content = loadFile(path.get)
    val trialsContent = loadFile(trialsPath.get)

    val trials = trialsContent.split("\n").drop(if (removePractice) 41 else 1) // drop header and practice rounds

    //implicit val system = ActorSystem("EpochFixerSystem")
    //implicit val materializer = ActorMaterializer()

    var codeMap = mutable.Map[Int, Int]()

    var sb = StringBuilder.newBuilder

    sb append "Latency Group Type Index\n"

    var i = 0
    var startTimestamp = 0.0
    var timeouts = 0

    // drop header and practice rounds
    content.split("\n").drop(if (removePractice) 41 else 1).toList.foreach ( row => {
      val s = new Scanner(row)
      var latency = s.nextDouble
      val order = s.nextInt
      //val group = trials(Math.floor(i / 2).toInt)
      var group = trials(i)
      val eventType = if (codeMap.getOrElse(order, 0)==0) "start" else "rt"

      if (codeMap.getOrElse(order, 0) >= 1)
        codeMap.put(order, 0)
      else
        codeMap.put(order, codeMap.getOrElse(order, 0)+1)

      if ("start".equalsIgnoreCase(eventType)) {
        latency = latency + 1.2 // add fixation, jitter, and averaged USB delay
        startTimestamp = latency
      } //{if ((i<40) && !removePractice) 1.2 else 1.2} // move from start-of-fixation to start-of-stimulus
      if ("rt".equalsIgnoreCase(eventType)) {
        //println(group)
        var rt = group.split(":")(1).toDouble
        latency = rt + startTimestamp + {if (rt<3.9) 0.2 else 0.0} // to compensate for jitter and delayed keyboard sensitivity
        group = group.split(":")(0)
        if (group==9 || group==12) timeouts+=1
        Seq(rt).filter(rt => rt>3.5 || rt<0.1).map{_ => group="12"; timeouts+=1} // timeout groups if rt>=3.5
      }
      sb append f"$latency%1.3f $group $eventType $order%1d\n"
      i += 1
    })

    println(s"$timeouts trials marked as timeout (code 12).")

    writeToFile(s"${rootDir}/misc/erp_epochs/${subject}_erp_action_epochs.txt", sb.mkString)
    writeToFile(s"${rootDir}/${subject}/${subject}_erp_action_epochs.txt", sb.mkString)

  }

  def loadFile(path: String): String = {
    IOSource.fromFile(path, "UTF-8").mkString
  }

  def writeToFile(path: String, str: String) = {
    Files.write(Paths.get(path), str.getBytes(StandardCharsets.UTF_8))
  }
}
