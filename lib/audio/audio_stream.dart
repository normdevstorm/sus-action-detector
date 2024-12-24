// import 'dart:async';
// import 'dart:io';
// import 'dart:typed_data';
// import 'package:flutter/foundation.dart';
// import 'package:record/record.dart';

// class UDPAudioStreamManager {
//   // Audio Recording Configuration
//   final Record _audioRecorder = Record();
  
//   // UDP Socket
//   RawDatagramSocket? _udpSocket;
  
//   // Stream Controllers
//   final StreamController<Uint8List> _audioStreamController = 
//       StreamController<Uint8List>.broadcast();

//   // Streaming Parameters
//   late InternetAddress _serverAddress;
//   late int _serverPort;

//   Future<void> initializeUDPStreaming({
//     required String serverIP,
//     required int serverPort,
//     int sampleRate = 44100,
//     int channels = 1,
//     int bitDepth = 16,
//   }) async {
//     try {
//       // Resolve Server Address
//       _serverAddress = await InternetAddress.lookup(serverIP);
//       _serverPort = serverPort;

//       // Create UDP Socket
//       _udpSocket = await RawDatagramSocket.bind(
//         InternetAddress.anyIPv4, 
//         0 // Let OS assign a random port
//       );

//       // Configure Audio Recording
//       if (await _audioRecorder.hasPermission()) {
//         final config = RecordConfig(
//           encoder: AudioEncoder.pcm16bit,
//           sampleRate: sampleRate,
//           numChannels: channels,
//           bitRate: bitDepth * sampleRate * channels,
//         );

//         // Start Audio Stream
//         await _audioRecorder.startStream(config)
//           .then((audioStream) {
//             // Listen to Audio Chunks
//             audioStream.listen(
//               (audioChunk) {
//                 // Convert to Uint8List
//                 Uint8List audioBytes = Uint8List.fromList(audioChunk);
                
//                 // Add to Stream Controller
//                 _audioStreamController.add(audioBytes);

//                 // Send via UDP
//                 _sendAudioChunkOverUDP(audioBytes);
//               },
//               onError: (error) {
//                 print('Audio Stream Error: $error');
//                 _stopStreaming();
//               },
//               cancelOnError: true,
//             );
//         });
//       }
//     } catch (e) {
//       print('UDP Streaming Initialization Error: $e');
//       _stopStreaming();
//     }
//   }

//   /// Send Audio Chunk via UDP
//   void _sendAudioChunkOverUDP(Uint8List audioChunk) {
//     try {
//       // Check UDP Socket
//       if (_udpSocket != null) {
//         // Implement Packet Sequencing
//         Uint8List packetWithSequence = _createSequencedPacket(audioChunk);

//         // Send UDP Datagram
//         _udpSocket!.send(
//           packetWithSequence, 
//           _serverAddress.first, 
//           _serverPort
//         );
//       }
//     } catch (e) {
//       print('UDP Send Error: $e');
//     }
//   }

//   /// Create Sequenced Packet for Reliable Transmission
//   Uint8List _createSequencedPacket(Uint8List audioChunk) {
//     // Packet Structure:
//     // [4 bytes Sequence Number][Audio Chunk Data]
//     int sequenceNumber = DateTime.now().millisecondsSinceEpoch;
    
//     ByteData packetData = ByteData(4 + audioChunk.length);
    
//     // Write Sequence Number
//     packetData.setUint32(0, sequenceNumber, Endian.big);
    
//     // Write Audio Chunk
//     for (int i = 0; i < audioChunk.length; i++) {
//       packetData.setUint8(4 + i, audioChunk[i]);
//     }

//     return packetData.buffer.asUint8List();
//   }

//   /// Implement Packet Loss Mitigation
//   void _handlePacketLossMitigation(Uint8List audioChunk) {
//     // Implement Forward Error Correction (FEC)
//     // or Packet Interpolation strategies
//   }

//   /// Stop UDP Audio Streaming
//   Future<void> _stopStreaming() async {
//     // Close Audio Stream Controller
//     await _audioStreamController.close();

//     // Close UDP Socket
//     _udpSocket?.close();

//     // Stop Audio Recorder
//     await _audioRecorder.stop();
//   }

//   /// Cleanup Method
//   void dispose() {
//     _stopStreaming();
//   }
// }

// /// UDP Audio Streaming Widget
// class UDPAudioStreamWidget extends StatefulWidget {
//   @override
//   _UDPAudioStreamWidgetState createState() => _UDPAudioStreamWidgetState();
// }

// class _UDPAudioStreamWidgetState extends State<UDPAudioStreamWidget> {
//   final UDPAudioStreamManager _streamManager = UDPAudioStreamManager();
  
//   bool _isStreaming = false;

//   void _toggleAudioStreaming() {
//     setState(() {
//       _isStreaming = !_isStreaming;
//     });

//     if (_isStreaming) {
//       _streamManager.initializeUDPStreaming(
//         serverIP: '192.168.1.100', // Replace with your server IP
//         serverPort: 12345,
//         sampleRate: 44100,
//         channels: 1,
//         bitDepth: 16
//       );
//     } else {
//       _streamManager.dispose();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return ElevatedButton(
//       onPressed: _toggleAudioStreaming,
//       child: Text(_isStreaming 
//         ? 'Stop UDP Streaming' 
//         : 'Start UDP Streaming'
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _streamManager.dispose();
//     super.dispose();
//   }
// }