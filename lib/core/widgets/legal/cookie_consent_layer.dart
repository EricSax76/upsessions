import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:upsessions/core/constants/app_routes.dart';
import 'package:upsessions/core/locator/locator.dart';
import 'package:upsessions/core/services/cookie_consent_service.dart';

class CookieConsentLayer extends StatefulWidget {
  const CookieConsentLayer({
    super.key,
    required this.child,
    this.cookieConsentService,
    this.isWebOverride,
  });

  final Widget child;
  final CookieConsentService? cookieConsentService;
  final bool? isWebOverride;

  @override
  State<CookieConsentLayer> createState() => _CookieConsentLayerState();
}

class _CookieConsentLayerState extends State<CookieConsentLayer> {
  late final CookieConsentService _cookieConsentService;

  @override
  void initState() {
    super.initState();
    _cookieConsentService =
        widget.cookieConsentService ?? locate<CookieConsentService>();
    _cookieConsentService.addListener(_refresh);
  }

  @override
  void dispose() {
    _cookieConsentService.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _openPreferences() async {
    final preferences = _cookieConsentService.preferences;
    var analytics = preferences.analytics;
    var preferenceCookies = preferences.preferences;
    var marketing = preferences.marketing;

    final result = await showModalBottomSheet<_ConsentSelection>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Preferencias de cookies',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Puedes modificar tu consentimiento en cualquier momento.',
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Cookies necesarias'),
                      subtitle: const Text(
                        'Siempre activas para seguridad y funcionamiento.',
                      ),
                      value: true,
                      onChanged: null,
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Cookies analíticas'),
                      subtitle: const Text(
                        'Nos ayudan a medir uso y mejorar producto.',
                      ),
                      value: analytics,
                      onChanged: (value) => setState(() => analytics = value),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Cookies de preferencias'),
                      subtitle: const Text(
                        'Guardan idioma y personalización no esencial.',
                      ),
                      value: preferenceCookies,
                      onChanged: (value) =>
                          setState(() => preferenceCookies = value),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Cookies de marketing'),
                      subtitle: const Text(
                        'Personalizan mensajes y campañas comerciales.',
                      ),
                      value: marketing,
                      onChanged: (value) => setState(() => marketing = value),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(sheetContext).pop(),
                          child: const Text('Cancelar'),
                        ),
                        const Spacer(),
                        FilledButton(
                          onPressed: () {
                            Navigator.of(sheetContext).pop(
                              _ConsentSelection(
                                analytics: analytics,
                                preferences: preferenceCookies,
                                marketing: marketing,
                              ),
                            );
                          },
                          child: const Text('Guardar selección'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (result == null) return;
    await _cookieConsentService.saveSelection(
      analytics: result.analytics,
      preferences: result.preferences,
      marketing: result.marketing,
    );
  }

  @override
  Widget build(BuildContext context) {
    final shouldRenderForWeb = widget.isWebOverride ?? kIsWeb;
    if (!shouldRenderForWeb) {
      return widget.child;
    }

    final showBanner = _cookieConsentService.shouldShowBanner;
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final buttonBottomOffset = showBanner
        ? 144 + bottomInset
        : 12 + bottomInset;

    return Stack(
      children: [
        widget.child,
        Positioned(
          left: 12,
          bottom: buttonBottomOffset,
          child: SafeArea(
            top: false,
            child: OutlinedButton.icon(
              onPressed: _openPreferences,
              icon: const Icon(Icons.privacy_tip_outlined, size: 18),
              label: const Text('Privacidad y cookies'),
            ),
          ),
        ),
        if (showBanner)
          Positioned(
            left: 12,
            right: 12,
            bottom: 12 + bottomInset,
            child: SafeArea(
              top: false,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Usamos cookies para seguridad, funcionamiento y analítica opcional.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          TextButton(
                            onPressed: () =>
                                context.push(AppRoutes.legalCookies),
                            child: const Text('Política de cookies'),
                          ),
                          TextButton(
                            onPressed: _openPreferences,
                            child: const Text('Configurar'),
                          ),
                          OutlinedButton(
                            onPressed: _cookieConsentService.rejectOptional,
                            child: const Text('Rechazar'),
                          ),
                          FilledButton(
                            onPressed: _cookieConsentService.acceptAll,
                            child: const Text('Aceptar todo'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _ConsentSelection {
  const _ConsentSelection({
    required this.analytics,
    required this.preferences,
    required this.marketing,
  });

  final bool analytics;
  final bool preferences;
  final bool marketing;
}
