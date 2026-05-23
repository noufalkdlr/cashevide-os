/**
 * ./src/classes/incubation/branding.ts
 * penguins-eggs v.25.7.x / ecmascript 2020
 * author: Piero Proietti
 * email: piero.proietti@gmail.com
 * license: MIT
 */
import yaml from 'js-yaml';
/**
 *
 * @param remix
 * @param distro
 * @param theme
 * @param verbose
 * @returns
 */
export function branding(remix, distro, theme = '', verbose = false) {
    const { bugReportUrl, homeUrl, supportUrl } = distro;
    // Li ridenomino per calamares
    const productUrl = homeUrl;
    // const supportUrl= supportUrl
    const releaseNotesUrl = bugReportUrl;
    const knownIssuesUrl = 'https://github.com/pieroproietti/penguins-eggs/issues/';
    const productName = remix.versionName; // Questa va nel titolo ed in basso
    const shortProductName = remix.fullname;
    const today = new Date();
    const version = today.toISOString().split('T')[0]; // 2021-09-30
    const shortVersion = version.split('-').join('.'); // 2021.09.30
    const versionedName = remix.fullname + ' (' + shortVersion + ')';
    const shortVersionedName = remix.versionName + ' ' + version;
    /**
     * some distros: Devuan, LMDE, syslinuxos
     * must have: bootloaderEntryName=Debian
     * to work on EFI
     */
    let bootloaderEntryName = '';
    const distroId = distro.distroId.toLowerCase();
    if (distroId === 'devuan' || distroId === 'lmde' || distroId === 'syslinuxos') {
        bootloaderEntryName = 'Debian';
    }
    else {
        bootloaderEntryName = distro.distroId;
    }
    const productLogo = `${remix.branding}-logo.png`;
    const productIcon = `${remix.branding}-logo.png`;
    const productWelcome = 'welcome.png';
    const slideshow = 'show.qml';
    const branding = {
        componentName: 'eggs',
        images: {
            productIcon: 'eggs-logo.png',
            productLogo: 'eggs-logo.png',
            productWelcome: 'welcome.png'
        },
        slideshow: 'show.qml',
        slideshowAPI: 1,
        strings: {
            bootloaderEntryName: 'Cashevide OS',
            knownIssuesUrl: 'https://github.com/pieroproietti/penguins-eggs/issues/',
            productName: 'Cashevide OS 1.0',
            productUrl: 'https://cashevide.com/',
            releaseNotesUrl: 'https://cashevide.com/',
            shortProductName: 'Cashevide OS',
            shortVersion: '1.0',
            shortVersionedName: 'Cashevide OS 1.0',
            supportUrl: 'https://cashevide.com/',
            version: '1.0',
            versionedName: 'Cashevide OS 1.0'
        },
        style: {
            SidebarBackground: '#000000',
            sidebarBackground: '#000000',
            SidebarBackgroundCurrent: '#262626',
            sidebarBackgroundCurrent: '#262626',
            SidebarText: '#999999',
            sidebarText: '#999999',
            SidebarTextCurrent: '#FFFFFF',
            sidebarTextCurrent: '#FFFFFF'
        },
        welcomeStyleCalamares: true
    };
    return yaml.dump(branding);
}
