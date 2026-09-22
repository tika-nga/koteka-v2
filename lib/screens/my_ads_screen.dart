import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:flutter_marketplace_template/models/annonce.dart';
import 'package:flutter_marketplace_template/screens/place_screen.dart';

class MyAdsScreen extends StatefulWidget {
  const MyAdsScreen({super.key});

  @override
  State<MyAdsScreen> createState() => _MyAdsScreenState();
}

class _MyAdsScreenState extends State<MyAdsScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;

  bool _isLoading = true;
  String? _errorMessage;

  List<Annonce> _annonces = [];

  @override
  void initState() {
    super.initState();
    _loadMyAds();
  }

  Future<void> _loadMyAds() async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = 'Vous devez être connecté.';
        _annonces = [];
      });

      return;
    }

    try {
      if (mounted) {
        setState(() {
          _isLoading = true;
          _errorMessage = null;
        });
      }

      final response = await _supabase
          .from('annonces')
          .select()
          .eq('user_id', user.id)
          .order(
            'created_at',
            ascending: false,
          );

      final rows =
          List<Map<String, dynamic>>.from(
        response,
      );

      final annonces =
          rows.map(Annonce.fromJson).toList();

      if (!mounted) return;

      setState(() {
        _annonces = annonces;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage =
            'Impossible de charger vos annonces.';
      });
    }
  }

  bool _isExpired(Annonce annonce) {
    final expiresAt = annonce.expiresAt;

    if (expiresAt == null) {
      return false;
    }

    return !expiresAt.isAfter(
      DateTime.now(),
    );
  }

  bool _canRenew(Annonce annonce) {
    final expiresAt = annonce.expiresAt;

    if (expiresAt == null) {
      return false;
    }

    final now = DateTime.now();

    if (_isExpired(annonce)) {
      return true;
    }

    final renewalStart = expiresAt.subtract(
      const Duration(days: 7),
    );

    return !now.isBefore(renewalStart);
  }

  bool _canLowerPrice(Annonce annonce) {
    if (annonce.isService) {
      return false;
    }

    if (_isExpired(annonce)) {
      return false;
    }

    if (!annonce.isActive) {
      return false;
    }

    if (annonce.priceDropCount >= 2) {
      return false;
    }

    final now = DateTime.now();

    if (annonce.priceDropCount == 0) {
      final reference =
          annonce.renewedAt ??
              annonce.createdAt;

      if (reference == null) {
        return false;
      }

      return !now.isBefore(
        DateTime(
          reference.year,
          reference.month + 2,
          reference.day,
          reference.hour,
          reference.minute,
          reference.second,
        ),
      );
    }

    final lastDrop =
        annonce.lastPriceDropAt;

    if (lastDrop == null) {
      return false;
    }

    return !now.isBefore(
      DateTime(
        lastDrop.year,
        lastDrop.month + 2,
        lastDrop.day,
        lastDrop.hour,
        lastDrop.minute,
        lastDrop.second,
      ),
    );
  }

  Future<void> _renewAnnonce(
    Annonce annonce,
  ) async {
    final confirmed =
        await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Renouveler l’annonce',
          ),
          content: const Text(
            'Voulez-vous renouveler cette annonce ?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  false,
                );
              },
              child: const Text(
                'Annuler',
              ),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  true,
                );
              },
              child: const Text(
                'Renouveler',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      await _supabase.rpc(
        'renew_annonce',
        params: {
          'p_annonce_id': annonce.id,
        },
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Annonce renouvelée.',
          ),
        ),
      );

      await _loadMyAds();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Le renouvellement a échoué.',
          ),
        ),
      );
    }
  }

  Future<void> _showLowerPriceDialog(
    Annonce annonce,
  ) async {
    final controller =
        TextEditingController();

    final newPrice =
        await showDialog<int>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Baisser le prix',
          ),
          content: Column(
            mainAxisSize:
                MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                'Prix actuel : '
                '${annonce.price} FC',
              ),

              const SizedBox(height: 16),

              TextField(
                controller: controller,
                keyboardType:
                    TextInputType.number,
                autofocus: true,
                decoration:
                    const InputDecoration(
                  labelText:
                      'Nouveau prix',
                  suffixText: 'FC',
                  border:
                      OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                );
              },
              child: const Text(
                'Annuler',
              ),
            ),
            FilledButton(
              onPressed: () {
                final value =
                    int.tryParse(
                  controller.text
                      .replaceAll(
                        ' ',
                        '',
                      )
                      .trim(),
                );

                if (value == null ||
                    value <= 0) {
                  return;
                }

                Navigator.pop(
                  context,
                  value,
                );
              },
              child: const Text(
                'Confirmer',
              ),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (newPrice == null) {
      return;
    }

    try {
      await _supabase.rpc(
        'lower_annonce_price',
        params: {
          'p_annonce_id': annonce.id,
          'p_new_price': newPrice,
        },
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Le prix a été diminué.',
          ),
        ),
      );

      await _loadMyAds();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Cette baisse de prix '
            'n’est pas autorisée.',
          ),
        ),
      );
    }
  }

  Future<void> _openAnnonce(
    Annonce annonce,
  ) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PlaceScreen(
          annonce: annonce,
        ),
      ),
    );

    await _loadMyAds();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mes annonces',
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadMyAds,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return ListView(
        physics:
            const AlwaysScrollableScrollPhysics(),
        padding:
            const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 100),

          const Icon(
            Icons.error_outline,
            size: 48,
          ),

          const SizedBox(height: 16),

          Text(
            _errorMessage!,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          Center(
            child: FilledButton(
              onPressed: _loadMyAds,
              child: const Text(
                'Réessayer',
              ),
            ),
          ),
        ],
      );
    }

    if (_annonces.isEmpty) {
      return ListView(
        physics:
            const AlwaysScrollableScrollPhysics(),
        padding:
            const EdgeInsets.all(24),
        children: const [
          SizedBox(height: 100),

          Icon(
            Icons.inventory_2_outlined,
            size: 56,
          ),

          SizedBox(height: 16),

          Text(
            'Vous n’avez encore '
            'aucune annonce.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 17,
              fontWeight:
                  FontWeight.w500,
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      physics:
          const AlwaysScrollableScrollPhysics(),
      padding:
          const EdgeInsets.all(16),
      itemCount: _annonces.length,
      separatorBuilder: (_, __) =>
          const SizedBox(height: 12),
      itemBuilder: (
        context,
        index,
      ) {
        return _buildAnnonceCard(
          _annonces[index],
        );
      },
    );
  }

  Widget _buildAnnonceCard(
    Annonce annonce,
  ) {
    final expired =
        _isExpired(annonce);

    final active =
        annonce.isActive && !expired;

    final canLower =
        _canLowerPrice(annonce);

    final canRenew =
        _canRenew(annonce);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          _openAnnonce(annonce);
        },
        child: Padding(
          padding:
              const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  _buildImage(annonce),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                      children: [
                        Text(
                          annonce.title,
                          maxLines: 2,
                          overflow:
                              TextOverflow
                                  .ellipsis,
                          style:
                              const TextStyle(
                            fontSize: 17,
                            fontWeight:
                                FontWeight
                                    .w600,
                          ),
                        ),

                        const SizedBox(
                          height: 6,
                        ),

                        Text(
                          annonce.priceLabel,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight:
                                FontWeight
                                    .w700,
                            color:
                                Theme.of(
                              context,
                            )
                                    .colorScheme
                                    .primary,
                          ),
                        ),

                        const SizedBox(
                          height: 6,
                        ),

                        Text(
                          [
                            annonce.city,
                            annonce.district,
                          ]
                              .where(
                                (value) =>
                                    value
                                        .trim()
                                        .isNotEmpty,
                              )
                              .join(' • '),
                          maxLines: 1,
                          overflow:
                              TextOverflow
                                  .ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  _StatusBadge(
                    text: active
                        ? 'Active'
                        : 'Expirée',
                    icon: active
                        ? Icons
                            .check_circle_outline
                        : Icons
                            .schedule_outlined,
                  ),

                  if (annonce.isService) ...[
                    const SizedBox(width: 8),

                    const _StatusBadge(
                      text: 'Service',
                      icon: Icons
                          .handyman_outlined,
                    ),
                  ],
                ],
              ),

              if (canLower ||
                  canRenew) ...[
                const SizedBox(height: 14),

                const Divider(height: 1),

                const SizedBox(height: 12),

                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (canLower)
                      OutlinedButton.icon(
                        onPressed: () {
                          _showLowerPriceDialog(
                            annonce,
                          );
                        },
                        icon: const Icon(
                          Icons
                              .trending_down,
                        ),
                        label: const Text(
                          'Baisser le prix',
                        ),
                      ),

                    if (canRenew)
                      FilledButton.icon(
                        onPressed: () {
                          _renewAnnonce(
                            annonce,
                          );
                        },
                        icon: const Icon(
                          Icons
                              .autorenew,
                        ),
                        label: const Text(
                          'Renouveler l’annonce',
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage(
    Annonce annonce,
  ) {
    if (annonce.imageUrl
        .trim()
        .isEmpty) {
      return Container(
        width: 90,
        height: 90,
        decoration: BoxDecoration(
          color:
              Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest,
          borderRadius:
              BorderRadius.circular(10),
        ),
        child: const Icon(
          Icons.image_outlined,
          size: 34,
        ),
      );
    }

    return ClipRRect(
      borderRadius:
          BorderRadius.circular(10),
      child: Image.network(
        annonce.imageUrl,
        width: 90,
        height: 90,
        fit: BoxFit.cover,
        errorBuilder: (
          context,
          error,
          stackTrace,
        ) {
          return Container(
            width: 90,
            height: 90,
            color:
                Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest,
            child: const Icon(
              Icons.broken_image_outlined,
            ),
          );
        },
      ),
    );
  }
}

class _StatusBadge
    extends StatelessWidget {
  final String text;
  final IconData icon;

  const _StatusBadge({
    required this.text,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color:
            Theme.of(context)
                .colorScheme
                .surfaceContainerHighest,
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize:
            MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 15,
          ),

          const SizedBox(width: 5),

          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              fontWeight:
                  FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
