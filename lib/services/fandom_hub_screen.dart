import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FandomHubScreen extends StatefulWidget {
  const FandomHubScreen({super.key});

  @override
  State<FandomHubScreen> createState() => _FandomHubScreenState();
}

class _FandomHubScreenState extends State<FandomHubScreen> {
  final _supabase = Supabase.instance.client;
  final _messageController = TextEditingController();
  List<Map<String, dynamic>> _channels = [];
  Map<String, dynamic>? _selectedChannel;
  String _currentUserName = "SYSTEM NODE";
  bool _isLoadingChannels = true;

  @override
  void initState() {
    super.initState();
    _initializeHub();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _initializeHub() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user != null) {
        final profile = await _supabase.from('user_profiles').select('display_name').eq('id', user.id).maybeSingle();
        if (profile != null && mounted) {
          setState(() => _currentUserName = profile['display_name'] ?? 'USER NODE');
        }
      }

      final channelsData = await _supabase.from('community_channels').select().order('name');
      if (mounted) {
        setState(() {
          _channels = List<Map<String, dynamic>>.from(channelsData);
          if (_channels.isNotEmpty) _selectedChannel = _channels.first;
          _isLoadingChannels = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingChannels = false);
    }
  }

  Future<void> _transmitMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _selectedChannel == null) return;

    _messageController.clear();
    final user = _supabase.auth.currentUser;

    try {
      await _supabase.from('community_messages').insert({
        'channel_id': _selectedChannel!['id'],
        'sender_id': user?.id,
        'sender_name': _currentUserName.toUpperCase(),
        'message_body': text,
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('TRANSMISSION BLOCK: Security policy restriction.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xFF111111),
        title: Text(
          _selectedChannel != null ? '${_selectedChannel!['name']}' : 'FANDOM HUB CORE',
          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 2),
        ),
        elevation: 0,
      ),
      body: _isLoadingChannels
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF39FF14)))
          : Column(
              children: [
                // ================= HORIZONTAL CHANNEL SECTORS =================
                Container(
                  height: 50,
                  color: const Color(0xFF0A0A0A),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _channels.length,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemBuilder: (context, index) {
                      final chan = _channels[index];
                      final isSelected = _selectedChannel?['id'] == chan['id'];
                      return GestureDetector(
                        onTap: () => setState(() => _selectedChannel = chan),
                        child: Container(
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF161616) : Colors.transparent,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: isSelected ? const Color(0xFF39FF14) : Colors.transparent),
                          ),
                          child: Center(
                            child: Text(
                              chan['name'],
                              style: TextStyle(
                                color: isSelected ? const Color(0xFF39FF14) : Colors.grey,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // ================= REAL-TIME TRAFFIC FEED =================
                Expanded(
                  child: _selectedChannel == null
                      ? const Center(child: Text('SELECT SYSTEM CHANNEL NODE', style: TextStyle(color: Colors.grey)))
                      : StreamBuilder<List<Map<String, dynamic>>>(
                          stream: _supabase
                              .from('community_messages')
                              .stream(primaryKey: ['id'])
                              .eq('channel_id', _selectedChannel!['id'])
                              .order('created_at', ascending: false),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const Center(child: CircularProgressIndicator(color: Color(0xFF39FF14)));
                            }
                            final messages = snapshot.data!;
                            if (messages.isEmpty) {
                              return const Center(
                                child: Text('CHANNEL STREAM DORMANT // AWAITING DATA',
                                    style: TextStyle(color: Color(0xFF222222), fontSize: 11, letterSpacing: 1)),
                              );
                            }
                            return ListView.builder(
                              reverse: true,
                              itemCount: messages.length,
                              padding: const EdgeInsets.all(24),
                              itemBuilder: (context, index) {
                                final msg = messages[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  // 🎯 FIXED: Changed from a Container to a Column to use crossAxisAlignment correctly
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            msg['sender_name'].toString().toUpperCase(),
                                            style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'NODE ACTIVE',
                                            style: TextStyle(color: Colors.white.withValues(alpha: 0.15), fontSize: 8, fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        msg['message_body'] ?? '',
                                        style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.4),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        ),
                ),

                // ================= SIGNAL TEXT INJECTOR =================
                Container(
                  padding: const EdgeInsets.only(left: 24, right: 24, bottom: 32, top: 12),
                  color: const Color(0xFF0A0A0A),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                          decoration: InputDecoration(
                            hintText: 'Transmit signal packet payload...',
                            hintStyle: const TextStyle(color: Colors.grey, fontSize: 12),
                            filled: true,
                            fillColor: Colors.black,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: Color(0xFF1A1A1A))),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: Color(0xFF39FF14))),
                          ),
                          onSubmitted: (_) => _transmitMessage(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        icon: const Icon(Icons.satellite_alt, color: Color(0xFF39FF14)),
                        onPressed: _transmitMessage,
                      ),
                    ],
                  ), // 🎯 FIXED: Re-added missing closing paren for the Row
                ),
              ],
            ),
    );
  }
}