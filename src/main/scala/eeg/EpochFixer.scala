package eeg

import java.nio.charset.StandardCharsets
import java.nio.file.{Files, Paths}
import java.util.Scanner

import akka.actor.ActorSystem
import akka.stream.ActorMaterializer
import akka.stream.scaladsl._

import scala.collection.mutable
import scala.io.{Source => IOSource}

/**
  * To fix WinEEG/PsychoPy labels, and prepare epoch files for EEGLAB
  */
object EpochFixer extends App {
  val path = Option(args(0))

  val content = loadFile(path.get)

  //implicit val system = ActorSystem("EpochFixerSystem")
  //implicit val materializer = ActorMaterializer()

  var codeMap = mutable.Map[Int, Int]()

  var sb = StringBuilder.newBuilder

  sb append "Latency  Event  Type"
  sb append "\n"

  content.split("\n").toList.foreach ( row => {
    if (!row.contains("Latency")) {
      val s = new Scanner(row)
      val lat = s.nextDouble
      val typ = s.nextInt
      codeMap.put(typ, codeMap.getOrElse(typ, 0)+1)
      if (codeMap.getOrElse(typ, 0)>1)
        codeMap.put(typ, 0)
      val erptyp = if (codeMap.getOrElse(typ, 0)==0) "target" else "rt"
      sb append s"$lat  $typ  $erptyp"
      sb append "\n"
    }
  })

  writeToFile(path.get + ".events", sb.mkString)

  /*
  val flow = Source(content.split("\n").toList) via
    Flow[String].map(elem => elem) to
    Sink.foreach(println)

  flow.run()
  */

  def loadFile(path: String): String = {
    IOSource.fromFile(path, "UTF-8").mkString
  }

  def writeToFile(path: String, str: String) = {
    Files.write(Paths.get(path), str.getBytes(StandardCharsets.UTF_8))
  }
}