import 'dart:async';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../data/iot/datasource/iot_realtime_datasource_impl.dart';
import '../../data/iot/datasource/iot_realtime_datasource_impl_windows.dart';
import '../../domain/iot/repository/iot_realtime_repository.dart';

class AudioStreamingService {
  final String serverHost;
  final int serverPort;
  final AudioPlayer _audioPlayer = AudioPlayer();

  Socket? _tcpSocket;
  WebSocketChannel? _webSocket;

  AudioRecorder? _audioRecorder;
  StreamSubscription? _audioSubscription;
  bool _isInitialized = false;
  final bool _isRecording = false;

  AudioStreamingService({
    required this.serverHost,
    required this.serverPort,
  });

  Future<bool> initialize() async {
    if (_isInitialized) return true;
    try {
      if (!await _requestPermissions()) {
        throw 'Microphone permission denied';
      }

      _audioRecorder = AudioRecorder();

      if (kIsWeb) {
        _webSocket = WebSocketChannel.connect(
          Uri.parse('ws://$serverHost:$serverPort'),
        );
        // await _webSocket?.ready;
        _isInitialized = true;
      } else {
        _tcpSocket = await Socket.connect(serverHost, serverPort);
        _isInitialized = true;
        _tcpSocket?.listen(
          (data) => print('Received: ${data.length} bytes'),
          onError: (error) => print('TCP Error: $error'),
          onDone: () => print('TCP connection closed'),
        );
      }
      return _isInitialized;
    } catch (e) {
      print('Initialization Error: $e');
      return false;
    }
  }

  Future<bool> _requestPermissions() async {
    if (kIsWeb) return true;

    if (Platform.isAndroid || Platform.isIOS) {
      final status = await Permission.microphone.request();
      return status == PermissionStatus.granted;
    }
    return true;
  }

  Future<void> startStreaming() async {
    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) return;
    }

    try {
      const config = RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        sampleRate: 44100,
        numChannels: 1,
      );

      final audioStream = await _audioRecorder?.startStream(config);

      _audioSubscription = audioStream?.listen(
        (data) => _sendAudioData(data),
        onError: (error) => print('Audio Stream Error: $error'),
      );
    } catch (e) {
      print('Start Streaming Error: $e');
    }
  }

  void _sendAudioData(Uint8List audioData) async {
    try {
      if (kIsWeb) {
        // _webSocket?.sink.add(audioData.buffer.asByteData());
        // print('Sent ${audioData.length} bytes via TCP');

        // Calculate timing
        const int chunkSize = 1024; // bytes per chunk
        const int sampleRate = 44100; // samples per second
        const int bytesPerSample = 2; // 16-bit audio

        // Time for one chunk (ms) = (chunk_size / bytes_per_sample) / sample_rate * 1000
        const chunkDuration = (chunkSize / bytesPerSample) / sampleRate * 1000;

        for (var i = 0; i < audioData.length; i += chunkSize) {
          final end = (i + chunkSize < audioData.length)
              ? i + chunkSize
              : audioData.length;

          final chunk = audioData.sublist(i, end);
          _webSocket?.sink.add(chunk.buffer.asInt16List());
          print('Sent ${chunk.buffer.asInt16List().toString()} bytes via TCP');

          // Delay matches audio timing (half of chunk duration to maintain buffer)
          await Future.delayed(
              const Duration(milliseconds: (chunkDuration ~/ 2)));
        }
      } else {
        _tcpSocket?.add(audioData);
        print('Sent ${audioData.length} bytes via TCP');
      }
    } catch (e) {
      print('Send Audio Data Error: $e');
    }
  }

  Future<void> stopStreaming() async {
    try {
      await _audioSubscription?.cancel();
      await _audioRecorder?.stop();
    } catch (e) {
      print('Stop Streaming Error: $e');
    }
  }

  void dispose() {
    _audioSubscription?.cancel();
    _audioRecorder?.dispose();
    // _udpSocket?.close();
    _tcpSocket?.close();

    _webSocket?.sink.close();
    _isInitialized = false;
  }
}

class AudioStreamingScreen extends StatefulWidget {
  const AudioStreamingScreen({super.key});

  @override
  State<AudioStreamingScreen> createState() => _AudioStreamingScreenState();
}

class _AudioStreamingScreenState extends State<AudioStreamingScreen> {
  late AudioStreamingService _audioService;
  bool _isStreaming = false;
  bool _isInitialized = false;
  String? _recordedFilePath;
  bool _isRecording = false;
  final _audioPlayer = AudioPlayer();
  final _audioRecorder = AudioRecorder();
  final IotRealtimeRepository iotRealtimeRepository =( TargetPlatform.windows == defaultTargetPlatform && !kIsWeb) ? IotRealtimeDatasourceImplWindows() :
      IotRealtimeDatasourceImpl();

  @override
  void initState() {
    super.initState();
    _audioService = AudioStreamingService(
      serverHost: '167.172.78.230', // Replace with your server IP
      serverPort: 8020, // Replace with your server port
    );
    _initializeService();
  }

  Future<void> _startRecording() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}\\audio.wav';

    await _audioRecorder.start(
        const RecordConfig(
            encoder: AudioEncoder.pcm16bits, sampleRate: 44100, numChannels: 1),
        path: path);
    setState(() => _isRecording = true);
  }

  Future<void> _stopRecording() async {
    await _audioRecorder.stop();
    setState(() => _isRecording = false);
  }

  Future<void> _playRecording() async {
    if (_recordedFilePath != null) {
      await _audioPlayer.setSourceUrl(_recordedFilePath!);
      await _audioPlayer.play(_audioPlayer.source!);
    }
  }

  Future<void> _initializeService() async {
    final initialized = await _audioService.initialize();
    setState(() => _isInitialized = initialized);
  }

  Future<void> _toggleStreaming() async {
    if (!_isInitialized) return;

    setState(() => _isStreaming = !_isStreaming);

    if (_isStreaming) {
      await _audioService.startStreaming();
    } else {
      await _audioService.stopStreaming();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Audio Streaming'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!_isInitialized)
              const CircularProgressIndicator()
            else
              ElevatedButton.icon(
                onPressed: _toggleStreaming,
                icon: Icon(_isStreaming ? Icons.stop : Icons.mic),
                label:
                    Text(_isStreaming ? 'Stop Streaming' : 'Start Streaming'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  backgroundColor: _isStreaming ? Colors.red : Colors.blue,
                ),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () =>
                  _isRecording ? _stopRecording() : _startRecording(),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isRecording ? Colors.red : Colors.green,
              ),
              child: Text(_isRecording ? 'Stop Recording' : 'Start Recording'),
            ),
            if (_recordedFilePath != null) ...[
              10.verticalSpace,
              ElevatedButton(
                onPressed: _playRecording,
                child: const Text('Play Recording'),
              ),
              Text('File saved at: $_recordedFilePath'),
            ],
            const Text("Door"),
            StreamBuilder<bool>(
                stream: iotRealtimeRepository.getDoorStatus(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting)
                    return const CircularProgressIndicator();
                  if (snapshot.hasError)
                    return Text("Error: ${snapshot.error}");
                  if (snapshot.hasData)
                    return Text("Door Status: ${snapshot.data}");
                  return const SizedBox();
                })
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }
}
