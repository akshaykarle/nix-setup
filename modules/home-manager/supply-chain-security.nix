{ pkgs, ... }:
{
  home.sessionPath = [ "$HOME/.npm-global/bin" ];

  home.file = {
    npmrc = {
      target = ".config/npm/npmrc";
      text = ''
        # Supply chain security
        min-release-age=7
        ignore-scripts=true
        save-exact=true
        audit=true
        package-lock=true
        registry=https://registry.npmjs.org/

        # Writable global install location (nix store is read-only)
        prefix=''${HOME}/.npm-global
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
