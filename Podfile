platform :ios, '11.0'

def shared
    pod 'GRDB.swift'
end

target 'GRDBKit' do
    use_frameworks!

    shared

    # Pods for meetr
    target 'GRDBKitTests' do
        inherit! :search_paths

        shared
    end
end
