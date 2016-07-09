// Copyright (c) 2016 iAchieved.it LLC
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software
// and associated documentation files (the "Software"), to deal in the Software without restriction,
// including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so,
// subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all copies or substantial
// portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT
// LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, 
// WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE
// OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import TCPSSL
//import Foundation

guard Process.arguments.count == 4 else {
  print("Usage:  server certificatePath keyPath certificateChainPath")
  exit(0)
}

let certificatePath      = Process.arguments[1]
let keyPath              = Process.arguments[2]
let certificateChainPath = Process.arguments[3]

do {
  let sslServer = try TCPSSLServer(port:8443,
                                   certificate:certificatePath,
                                   privateKey:keyPath,
                                   certificateChain:certificateChainPath)

  print("Listening for connections")
  while true {
    do {
      let connection = try sslServer.accept(timingOut:-1)
      co {
        print("Client connected")
        do {
          let data = try connection.receive(upTo:1024)
          print("Client data received:  \(data)")
          let reversed = String(String(data).characters.reversed())
          print("Sending data:  \(reversed)")
          try connection.send(Data(reversed), timingOut:-1)
        } catch let dataError {
          print("Client connection error:  \(dataError)")
        }
      }
    } catch {
      print("Server accept error:  \(error)")
    }
  }

} catch let serverError {
  print("Error:  \(serverError)")
}
