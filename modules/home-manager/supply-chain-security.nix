{ pkgs, ... }:
{
  home.file = {
    npmrc = {
      target = ".config/npm/npmrc";
      text = ''
        # Supply chain security
        min-release-age=7d
        ignore-scripts=true
        save-exact=true
        audit=true
        package-lock=true
        registry=https://registry.npmjs.org/
        email=npm requires email to be set but doesn't use the value
      ''
      + pkgs.lib.optionalString pkgs.stdenv.isDarwin ''

        # Azure DevOps Platforms registry
        //pkgs.dev.azure.com/AxiCore/Platforms/_packaging/Platforms/npm/registry/:username=''${AZURE_NPM_USERNAME}
        //pkgs.dev.azure.com/AxiCore/Platforms/_packaging/Platforms/npm/registry/:_password=''${AZURE_NPM_PASSWORD}
        //pkgs.dev.azure.com/AxiCore/Platforms/_packaging/Platforms/npm/:username=''${AZURE_NPM_USERNAME}
        //pkgs.dev.azure.com/AxiCore/Platforms/_packaging/Platforms/npm/:_password=''${AZURE_NPM_PASSWORD}
        //pkgs.dev.azure.com/AxiCore/Platforms/_packaging/Platforms/npm/:email=npm requires email to be set but doesn't use the value

        # Azure DevOps Portals registry
        //pkgs.dev.azure.com/AxiCore/Portals/_packaging/npm_axi_portals/npm/registry/:username=''${AZURE_NPM_USERNAME}
        //pkgs.dev.azure.com/AxiCore/Portals/_packaging/npm_axi_portals/npm/registry/:_password=''${AZURE_NPM_PASSWORD}
        //pkgs.dev.azure.com/AxiCore/Portals/_packaging/npm_axi_portals/npm/:username=''${AZURE_NPM_USERNAME}
        //pkgs.dev.azure.com/AxiCore/Portals/_packaging/npm_axi_portals/npm/:_password=''${AZURE_NPM_PASSWORD}
        //pkgs.dev.azure.com/AxiCore/Portals/_packaging/npm_axi_portals/npm/:email=npm requires email to be set but doesn't use the value

        # Accertify registry
        //repository.device.accertify.com/artifactory/api/npm/inmobile-npm/:email=''${ACCERTIFY_NPM_USERNAME}
        //repository.device.accertify.com/artifactory/api/npm/inmobile-npm/:_authToken=''${ACCERTIFY_NPM_TOKEN}
      '';
    };
    uv-config = {
      target = ".config/uv/uv.toml";
      text = ''
        # Supply chain protection: refuse packages newer than 7 days
        exclude-newer = "7 days"
      '';
    };
    maven-settings = {
      target = ".m2/settings.xml";
      text = ''
        <?xml version="1.0" encoding="UTF-8"?>
        <settings xmlns="http://maven.apache.org/SETTINGS/1.2.0"
                  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                  xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.2.0 https://maven.apache.org/xsd/settings-1.2.0.xsd">
          <profiles>
            <profile>
              <id>security-defaults</id>
              <repositories>
                <repository>
                  <id>central</id>
                  <url>https://repo.maven.apache.org/maven2</url>
                  <releases>
                    <enabled>true</enabled>
                    <checksumPolicy>fail</checksumPolicy>
                  </releases>
                  <snapshots>
                    <enabled>false</enabled>
                  </snapshots>
                </repository>
              </repositories>
              <pluginRepositories>
                <pluginRepository>
                  <id>central</id>
                  <url>https://repo.maven.apache.org/maven2</url>
                  <releases>
                    <checksumPolicy>fail</checksumPolicy>
                  </releases>
                  <snapshots>
                    <enabled>false</enabled>
                  </snapshots>
                </pluginRepository>
              </pluginRepositories>
            </profile>
          </profiles>
          <activeProfiles>
            <activeProfile>security-defaults</activeProfile>
          </activeProfiles>
        </settings>
      '';
    };
  };
}
