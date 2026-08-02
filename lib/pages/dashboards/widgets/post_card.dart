import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:spotlight_connect/models/user_model.dart';

import 'package:spotlight_connect/models/comment_model.dart';
import 'package:spotlight_connect/models/post_model.dart';
import 'package:spotlight_connect/pages/profile/profile_sheet.dart';
import 'package:spotlight_connect/providers/app_auth_provider.dart';
import 'package:spotlight_connect/services/post_service.dart';
import 'package:spotlight_connect/theme.dart';
import 'package:spotlight_connect/widgets/viewport_constrained_sheet.dart';

class PostCard extends StatelessWidget {
  const PostCard({super.key, required this.post});

  final PostModel post;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final service = context.watch<PostService>();
    final liked = service.isLiked(post.postId);
    final reposted = service.isReposted(post.postId);
    final saved = service.isSaved(post.postId);

    final roleLabel = switch (post.authorPrimaryRole) {
      'talent' => 'Talent',
      'business' => 'Business',
      'admin' => 'Admin',
      _ => 'Audience',
    };

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onDoubleTap: () => context.read<PostService>().toggleLike(post.postId),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.22),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (post.repostOfPostId != null) ...[
              _RepostAttribution(
                reposterName: post.authorDisplayName,
                reposterRole: post.authorPrimaryRole,
                // Avoid placeholder identity labels like "Unknown" for launch audits.
                // If the feed does not include original author profile data yet,
                // show a neutral label instead of implying a user identity.
                originalAuthorName:
                    (post.repostOfAuthorDisplayName?.trim().isNotEmpty ?? false)
                    ? post.repostOfAuthorDisplayName!
                    : 'Original post',
                originalAuthorRole:
                    post.repostOfAuthorPrimaryRole ?? 'audience',
                originalText: post.repostOfText ?? '',
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () => ProfileSheet.show(
                    context,
                    userId: post.authorId,
                    displayName: post.authorDisplayName,
                    primaryRole: post.authorPrimaryRole,
                  ),
                  borderRadius: BorderRadius.circular(999),
                  child: _RoleAvatar(
                    role: post.authorPrimaryRole,
                    label: post.authorDisplayName,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: () => ProfileSheet.show(
                                context,
                                userId: post.authorId,
                                displayName: post.authorDisplayName,
                                primaryRole: post.authorPrimaryRole,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 2,
                                ),
                                child: Text(
                                  post.authorDisplayName,
                                  style: theme.textTheme.titleSmall?.bold,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          _RoleBadge(
                            label: roleLabel,
                            role: post.authorPrimaryRole,
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _timeText(post.createdAt),
                        style: theme.textTheme.labelSmall?.withColor(
                          theme.colorScheme.onSurfaceVariant,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'More',
                  onPressed: () => _openMore(context),
                  icon: Icon(
                    Icons.more_horiz,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            if (post.text.trim().isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              Text(
                post.text,
                style: theme.textTheme.bodyLarge?.copyWith(height: 1.45),
              ),
            ],
            if (post.tags.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: post.tags
                    .take(6)
                    .map((t) => _TagChip(tag: t))
                    .toList(),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                _ActionPill(
                  icon: liked ? Icons.favorite : Icons.favorite_border,
                  label: '${post.likeCount}',
                  color: liked
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                  onTap: () =>
                      context.read<PostService>().toggleLike(post.postId),
                ),
                const SizedBox(width: 8),
                _ActionPill(
                  icon: Icons.chat_bubble_outline,
                  label: '${post.commentCount}',
                  color: theme.colorScheme.onSurfaceVariant,
                  onTap: () => showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => ViewportConstrainedSheet(
                      child: CommentsSheet(post: post),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _ActionPill(
                  icon: reposted ? Icons.repeat_on_outlined : Icons.repeat,
                  label: '${post.repostCount}',
                  color: reposted
                      ? theme.colorScheme.secondary
                      : theme.colorScheme.onSurfaceVariant,
                  onTap: () {
                    final user = context.read<AppAuthProvider>().currentUser;
                    if (user == null) return;
                    context.read<PostService>().toggleRepost(
                      postId: post.postId,
                      reposterId: user.userId,
                      reposterDisplayName: user.displayName,
                      reposterPrimaryRole: user.activeRole,
                    );
                  },
                ),
                const Spacer(),
                IconButton(
                  tooltip: saved ? 'Saved' : 'Save',
                  onPressed: () =>
                      context.read<PostService>().toggleSave(post.postId),
                  icon: Icon(
                    saved ? Icons.bookmark : Icons.bookmark_border,
                    color: saved
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                IconButton(
                  tooltip: 'Share',
                  onPressed: () => _openShareSheet(context),
                  icon: Icon(
                    Icons.share_outlined,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _share(BuildContext context) async {
    final shareText = _shareText(post);
    try {
      await Clipboard.setData(ClipboardData(text: shareText));
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Copied to clipboard'),
          behavior: SnackBarBehavior.floating,
          showCloseIcon: true,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      debugPrint('Share copy failed: $e');
    }
  }

  void _openShareSheet(BuildContext context) {
    final theme = Theme.of(context);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ViewportConstrainedSheet(
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.35),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: AppSpacing.paddingLg,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Share',
                          style: theme.textTheme.titleLarge?.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () => context.pop(),
                        icon: Icon(
                          Icons.close,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      Icons.copy,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    title: Text(
                      'Copy text',
                      style: theme.textTheme.titleSmall?.bold,
                    ),
                    subtitle: Text(
                      'Copies a spotlight-ready caption',
                      style: theme.textTheme.bodySmall?.withColor(
                        theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    onTap: () async {
                      context.pop();
                      await _share(context);
                    },
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      Icons.link,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    title: Text(
                      'Copy link',
                      style: theme.textTheme.titleSmall?.bold,
                    ),
                    subtitle: Text(
                      'Copies a link you can share',
                      style: theme.textTheme.bodySmall?.withColor(
                        theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    onTap: () async {
                      final link = 'spotlight://post/${post.postId}';
                      try {
                        await Clipboard.setData(ClipboardData(text: link));
                        if (!context.mounted) return;
                        context.pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Link copied')),
                        );
                      } catch (e) {
                        debugPrint('Copy link failed: $e');
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _openMore(BuildContext context) {
    final theme = Theme.of(context);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ViewportConstrainedSheet(
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.35),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: AppSpacing.paddingLg,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Post actions',
                          style: theme.textTheme.titleLarge?.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () => context.pop(),
                        icon: Icon(
                          Icons.close,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      Icons.copy,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    title: Text(
                      'Copy',
                      style: theme.textTheme.titleSmall?.bold,
                    ),
                    subtitle: Text(
                      'Copy text for sharing',
                      style: theme.textTheme.bodySmall?.withColor(
                        theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    onTap: () async {
                      context.pop();
                      await _share(context);
                    },
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      Icons.report_outlined,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    title: Text(
                      'Report',
                      style: theme.textTheme.titleSmall?.bold,
                    ),
                    subtitle: Text(
                      'Helps keep Spotlight safe',
                      style: theme.textTheme.bodySmall?.withColor(
                        theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    onTap: () {
                      debugPrint('Report postId=${post.postId}');
                      context.pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Thanks — we’ll review this.'),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _shareText(PostModel post) {
    final role = switch (post.authorPrimaryRole) {
      'talent' => 'Talent',
      'business' => 'Business',
      'admin' => 'Admin',
      _ => 'Audience',
    };
    final tags = post.tags.isEmpty
        ? ''
        : '\n\n#${post.tags.take(6).join(' #')}';
    final body = post.repostOfPostId != null
        ? 'Repost by ${post.authorDisplayName} ($role)\n\n${post.repostOfText ?? ''}$tags'
        : '${post.authorDisplayName} ($role)\n\n${post.text}$tags';
    return 'SPOTLIGHT Connect — Spotlight Feed\n\n$body';
  }

  String _timeText(DateTime createdAt) {
    final delta = DateTime.now().difference(createdAt);
    if (delta.inMinutes < 60) return '${delta.inMinutes.clamp(1, 59)}m ago';
    if (delta.inHours < 24) return '${delta.inHours}h ago';
    return '${delta.inDays}d ago';
  }
}

class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.label, required this.role});

  final String label;
  final String role;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tint = switch (role) {
      'talent' => theme.colorScheme.primary,
      'business' => theme.colorScheme.secondary,
      'admin' => theme.colorScheme.tertiary,
      _ => theme.colorScheme.onSurfaceVariant,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: tint.withValues(alpha: 0.14),
        border: Border.all(color: tint.withValues(alpha: 0.22)),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.bold.withColor(
          theme.colorScheme.onSurface,
        ),
      ),
    );
  }
}

class _RepostAttribution extends StatelessWidget {
  const _RepostAttribution({
    required this.reposterName,
    required this.reposterRole,
    required this.originalAuthorName,
    required this.originalAuthorRole,
    required this.originalText,
  });

  final String reposterName;
  final String reposterRole;
  final String originalAuthorName;
  final String originalAuthorRole;
  final String originalText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        color: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.22,
        ),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.repeat, size: 18, color: theme.colorScheme.secondary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '$reposterName reposted',
                  style: theme.textTheme.labelLarge?.bold.withColor(
                    theme.colorScheme.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _RoleAvatar(role: originalAuthorRole, label: originalAuthorName),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      originalAuthorName,
                      style: theme.textTheme.titleSmall?.bold,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _roleLabel(originalAuthorRole),
                      style: theme.textTheme.labelSmall?.withColor(
                        theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            originalText,
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  String _roleLabel(String role) => switch (role) {
    'talent' => 'Talent',
    'business' => 'Business',
    'admin' => 'Admin',
    _ => 'Audience',
  };
}

class CommentsSheet extends StatefulWidget {
  const CommentsSheet({super.key, required this.post});

  final PostModel post;

  @override
  State<CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<CommentsSheet> {
  final _controller = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final viewInsets = MediaQuery.viewInsetsOf(context);
    final service = context.watch<PostService>();
    final user = context.select<AppAuthProvider, UserModel?>(
      (auth) => auth.currentUser,
    );
    final comments = service.commentsFor(widget.post.postId);

    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppRadius.xl),
          ),
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.35),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: AppSpacing.paddingLg,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Comments',
                        style: theme.textTheme.titleLarge?.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: Icon(
                        Icons.close,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    0,
                    AppSpacing.lg,
                    AppSpacing.lg,
                  ),
                  shrinkWrap: true,
                  itemCount: comments.isEmpty ? 1 : comments.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.md),
                  itemBuilder: (context, i) {
                    if (comments.isEmpty) {
                      return _EmptyComments();
                    }
                    return _CommentRow(comment: comments[i]);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  0,
                  AppSpacing.lg,
                  AppSpacing.lg,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        minLines: 1,
                        maxLines: 4,
                        textInputAction: TextInputAction.send,
                        decoration: InputDecoration(
                          hintText: user == null
                              ? 'Sign in to comment…'
                              : 'Write a comment…',
                          filled: true,
                          fillColor: theme.colorScheme.surfaceContainerHighest
                              .withValues(alpha: 0.22),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(999),
                            borderSide: BorderSide(
                              color: theme.colorScheme.outlineVariant
                                  .withValues(alpha: 0.35),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(999),
                            borderSide: BorderSide(
                              color: theme.colorScheme.outlineVariant
                                  .withValues(alpha: 0.35),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(999),
                            borderSide: BorderSide(
                              color: theme.colorScheme.primary.withValues(
                                alpha: 0.8,
                              ),
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                        ),
                        onSubmitted: (_) => _sendIfPossible(),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    IconButton.filled(
                      onPressed: user == null || _sending
                          ? null
                          : _sendIfPossible,
                      icon: Icon(
                        Icons.send,
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _sendIfPossible() async {
    final user = context.read<AppAuthProvider>().currentUser;
    if (user == null) return;
    final text = _controller.text;
    if (text.trim().isEmpty) return;

    setState(() => _sending = true);
    try {
      await context.read<PostService>().addComment(
        postId: widget.post.postId,
        authorId: user.userId,
        authorDisplayName: user.displayName,
        authorPrimaryRole: user.activeRole,
        text: text,
      );
      _controller.clear();
    } catch (e) {
      debugPrint('Add comment failed: $e');
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }
}

class _EmptyComments extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: AppSpacing.paddingLg,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        color: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.18,
        ),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.chat_bubble_outline,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              'Be the first to add context. High-signal comments only.',
              style: theme.textTheme.bodyMedium?.withColor(
                theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentRow extends StatelessWidget {
  const _CommentRow({required this.comment});

  final CommentModel comment;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: AppSpacing.paddingMd,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        color: theme.colorScheme.surface,
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.28),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _RoleAvatar(
            role: comment.authorPrimaryRole,
            label: comment.authorDisplayName,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        comment.authorDisplayName,
                        style: theme.textTheme.titleSmall?.bold,
                      ),
                    ),
                    Text(
                      _timeAgo(comment.createdAt),
                      style: theme.textTheme.labelSmall?.withColor(
                        theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  comment.text,
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final delta = DateTime.now().difference(dt);
    if (delta.inMinutes < 60) return '${delta.inMinutes.clamp(1, 59)}m';
    if (delta.inHours < 24) return '${delta.inHours}h';
    return '${delta.inDays}d';
  }
}

class _RoleAvatar extends StatelessWidget {
  const _RoleAvatar({required this.role, required this.label});

  final String role;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (IconData icon, Color tint) = switch (role) {
      'talent' => (Icons.mic_none, theme.colorScheme.primary),
      'business' => (Icons.handshake_outlined, theme.colorScheme.secondary),
      'admin' => (Icons.shield_outlined, theme.colorScheme.tertiary),
      _ => (Icons.person_outline, theme.colorScheme.primaryContainer),
    };

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: tint.withValues(alpha: 0.16),
            border: Border.all(color: tint.withValues(alpha: 0.35)),
          ),
          child: Icon(icon, color: tint),
        ),
        Positioned(
          right: -3,
          bottom: -3,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
              ),
            ),
            child: Text(
              label.isNotEmpty ? label.characters.first.toUpperCase() : 'S',
              style: theme.textTheme.labelSmall?.bold,
            ),
          ),
        ),
      ],
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.tag});

  final String tag;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.35,
        ),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.25),
        ),
      ),
      child: Text(
        '#$tag',
        style: theme.textTheme.labelMedium?.withColor(
          theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _ActionPill extends StatelessWidget {
  const _ActionPill({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.35),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 6),
            Text(label, style: theme.textTheme.labelLarge?.withColor(color)),
          ],
        ),
      ),
    );
  }
}
