window.config = {
  routerBasename: '/',
  showStudyList: true,
  defaultDataSourceName: 'dcm4chee',

  extensions: [
    '@ohif/extension-default',
    '@ohif/extension-cornerstone',
    '@ohif/extension-dicom-microscopy',
    '@ohif/extension-dicom-pdf',
    '@ohif/extension-dicom-video',
  ],

  modes: [
    '@ohif/mode-basic',
    '@ohif/mode-longitudinal',
    '@ohif/mode-tmtv',
  ],

  dicomWeb: [
    {
      name: 'DCM4CHEE PACS',
      wadoUriRoot: 'https://pacs-ui.osirl.com/dcm4chee-arc/aets/DCM4CHEE/wado',
      qidoRoot:    'https://pacs-ui.osirl.com/dcm4chee-arc/aets/DCM4CHEE/rs',
      wadoRoot:    'https://pacs-ui.osirl.com/dcm4chee-arc/aets/DCM4CHEE/rs',
    }
  ],

  oidc: [
    {
      authority: 'https://auth.osirl.com/realms/dcm4che',
      client_id: 'ohif',
      redirect_uri: 'https://ohif.osirl.com/callback',
      response_type: 'code',
      scope: 'openid profile email',
      automaticSilentRenew: true,
      silent_redirect_uri: 'https://ohif.osirl.com/silent-refresh.html',
      post_logout_redirect_uri: 'https://ohif.osirl.com/',
    },
  ],


  dataSources: [
    {
      namespace: '@ohif/extension-default.dataSourcesModule.dicomweb',
      sourceName: 'dcm4chee',
      configuration: {
        friendlyName: 'DCM4CHEE PACS',
        name: 'DCM4CHEE',
        qidoRoot: 'https://pacs-ui.osirl.com/dcm4chee-arc/aets/DCM4CHEE/rs',
        wadoRoot: 'https://pacs-ui.osirl.com/dcm4chee-arc/aets/DCM4CHEE/rs',
        wadoUriRoot: 'https://pacs-ui.osirl.com/dcm4chee-arc/aets/DCM4CHEE/wado',
        qidoSupportsIncludeField: true,
        supportsReject: false,
        supportsStow: false,
        imageRendering: 'wadors',
        thumbnailRendering: 'wadors',
        enableStudyLazyLoad: true,
        supportsFuzzyMatching: true,
        supportsWildcard: true,
      },
    },
  ],
};
