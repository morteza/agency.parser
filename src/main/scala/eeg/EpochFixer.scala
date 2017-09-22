package eeg

import java.nio.charset.StandardCharsets
import java.nio.file.{Files, Paths}
import java.util.Scanner

import akka.actor.ActorSystem
import akka.stream.ActorMaterializer
import akka.stream.scaladsl._
import eeg.EpochFixer.subject

import scala.collection.mutable
import scala.io.{Source => IOSource}

/**
  * To fix WinEEG/PsychoPy labels, and prepare epoch files for EEGLAB
  */
object EpochFixer extends App {
  val subject = Option(args(0))

  args.foreach{subject => createSubjectEpochs(subject, System.getProperty("user.home")+"/Desktop/data")}

  /*
  val flow = Source(content.split("\n").toList) via
    Flow[String].map(elem => elem) to
    Sink.foreach(println)

  flow.run()
  */

  def createSubjectEpochs(subject: String, rootDir: String): Unit = {
    if (subject == null || subject.trim.length!=3)
      return

    val removePractice = true

    val path = Option(s"${rootDir}/${subject}/${subject}_labels.txt")
    val trialsPath = Option(s"${rootDir}/${subject}/${subject}_trial_orders.txt")

    val content = loadFile(path.get)
    val trialsContent = loadFile(trialsPath.get)

    val trials = trialsContent.split("\n").drop(if (removePractice) 21 else 1) // drop header and practice rounds

    //implicit val system = ActorSystem("EpochFixerSystem")
    //implicit val materializer = ActorMaterializer()

    var codeMap = mutable.Map[Int, Int]()

    var sb = StringBuilder.newBuilder

    sb append "Latency Group Type Index\n"

    var i = 0

    // drop header and practice rounds
    content.split("\n").drop(if (removePractice) 41 else 1).toList.foreach ( row => {
      val s = new Scanner(row)
      var latency = s.nextDouble
      val order = s.nextInt
      val group = trials(Math.floor(i / 2).toInt)
      val eventType = if (codeMap.getOrElse(order, 0)==0) "start" else "rt"
      if (codeMap.getOrElse(order, 0) >= 1)
        codeMap.put(order, 0)
      else
        codeMap.put(order, codeMap.getOrElse(order, 0)+1)
      if ("start".equalsIgnoreCase(eventType)) latency = latency + {if ((i<40) && !removePractice) 1.0 else 2.0} // move from start-of-fixation to start-of-stimulus
      sb append s"$latency $group $eventType $order\n"
      i += 1
    })

    writeToFile(s"${rootDir}/${subject}/${subject}_eeg_epochs.txt", sb.mkString)

  }

  def loadFile(path: String): String = {
    IOSource.fromFile(path, "UTF-8").mkString
  }

  def writeToFile(path: String, str: String) = {
    Files.write(Paths.get(path), str.getBytes(StandardCharsets.UTF_8))
  }
}
